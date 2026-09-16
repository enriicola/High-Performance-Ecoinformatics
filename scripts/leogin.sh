#!/bin/bash
# https://docs.hpc.cineca.it/general/access.html

readonly CA_URL="https://sshproxy.hpc.cineca.it"
readonly CA_FINGERPRINT="2ae1543202304d3f434bdc1a2c92eff2cd2b02110206ef06317e70c1c1735ecd"
SECRETS_DIR="$(dirname "$0")/../secrets"
readonly SECRETS_DIR
readonly CONNECTION_FILE="$SECRETS_DIR/cineca.env"
readonly PASSWORD_FILE="$SECRETS_DIR/cineca.passwd"
readonly TOTP_SECRET_FILE="$SECRETS_DIR/cineca-totp.secret"

for SECRET_FILE in "$CONNECTION_FILE" "$PASSWORD_FILE" "$TOTP_SECRET_FILE"; do
    if [[ ! -s "$SECRET_FILE" ]]; then
        echo "Error: $SECRET_FILE is empty"
        exit 1
    fi
done
# Loaded at runtime from a gitignored credential file.
# shellcheck disable=SC1090
source "$CONNECTION_FILE"

for req_var in CINECA_EMAIL CINECA_USERNAME CINECA_HOST; do
    if [[ -z "${!req_var:-}" ]]; then
        echo "Missing $req_var in $CONNECTION_FILE" >&2
        exit 1
    fi
done

readonly USER_EMAIL="$CINECA_EMAIL"
readonly NICK="$CINECA_USERNAME"
readonly HOST="$CINECA_HOST"

# Check step-cli installed
if ! command -v step &> /dev/null; then
    echo "Error: step-cli not installed"
    echo "Install: sudo apt install step-cli"
    exit 1
fi

# Bootstrap (one-time config, safe to re-run)
echo "Configuring smallstep CA..."
step ca bootstrap --ca-url="$CA_URL" --fingerprint "$CA_FINGERPRINT" --force

# Use persistent socket so it survives script exit
export SSH_AUTH_SOCK="$HOME/.ssh/cineca-agent.sock"

# Start ssh-agent if not running on this socket
if ! ssh-add -l &>/dev/null; then
    rm -f "$SSH_AUTH_SOCK"
    eval "$(ssh-agent -a "$SSH_AUTH_SOCK")"
    echo "Started ssh-agent on $SSH_AUTH_SOCK"
else
    echo "Using existing ssh-agent"
fi

# Reuse a valid certificate without asking for credentials again.
CERTIFICATE="$(step ssh list --raw "$USER_EMAIL" | grep -- '-cert-v01@openssh.com ' || true)"
readonly CERTIFICATE
if [[ -n "$CERTIFICATE" ]] && ! step ssh needs-renewal <(printf '%s\n' "$CERTIFICATE") --expires-in 0s; then
    exec ssh "$NICK@$HOST"
fi

# CINECA enables Keycloak's direct grant, unlike its device and OOB flows.
PROVISIONER="$(step ca provisioner list | jq -c '.[] | select(.name == "cineca-hpc")')"
readonly PROVISIONER
CLIENT_ID="$(jq -r '.clientID' <<<"$PROVISIONER")"
readonly CLIENT_ID
CLIENT_SECRET=$(jq -r '.clientSecret' <<<"$PROVISIONER")
DISCOVERY_URL="$(jq -r '.configurationEndpoint' <<<"$PROVISIONER")"
readonly DISCOVERY_URL
TOKEN_ENDPOINT="$(curl --fail --silent --show-error "$DISCOVERY_URL" | jq -r '.token_endpoint')"
readonly TOKEN_ENDPOINT

PASSWORD=$(<"$PASSWORD_FILE")
OTP=$(oathtool --totp=SHA1 --base32 --digits=6 "@$TOTP_SECRET_FILE")
if ! TOKEN_RESPONSE=$(curl --silent --show-error "$TOKEN_ENDPOINT" \
    --data-urlencode grant_type=password \
    --data-urlencode client_id@<(printf '%s' "$CLIENT_ID") \
    --data-urlencode client_secret@<(printf '%s' "$CLIENT_SECRET") \
    --data-urlencode username@<(printf '%s' "$NICK") \
    --data-urlencode password@<(printf '%s' "$PASSWORD") \
    --data-urlencode totp@<(printf '%s' "$OTP") \
    --data-urlencode scope='openid email'); then
    unset PASSWORD OTP CLIENT_SECRET
    exit 1
fi
unset PASSWORD OTP CLIENT_SECRET

if ! TOKEN=$(jq -er '.id_token' <<<"$TOKEN_RESPONSE"); then
    jq -r '"CINECA login failed: " + (.error_description // .error // "unknown error")' <<<"$TOKEN_RESPONSE" >&2
    exit 1
fi
unset TOKEN_RESPONSE

step ssh login "$USER_EMAIL" --token "$TOKEN"
unset TOKEN
exec ssh "$NICK@$HOST"

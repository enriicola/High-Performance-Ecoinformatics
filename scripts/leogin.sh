#!/bin/bash
# https://docs.hpc.cineca.it/general/access.html

CA_URL="https://sshproxy.hpc.cineca.it"
CA_FINGERPRINT="2ae1543202304d3f434bdc1a2c92eff2cd2b02110206ef06317e70c1c1735ecd"
HOST="login.leonardo.cineca.it"
USER_EMAIL="${1:-}"
NICK="${2:-}"

[[ -n "$USER_EMAIL" ]] || read -r -p "CINECA email: " USER_EMAIL
[[ -n "$NICK" ]] || read -r -p "CINECA username: " NICK

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

# Get SSH certificate (opens browser for 2FA)
step ssh login "$USER_EMAIL" --provisioner cineca-hpc

ssh "$NICK@$HOST"

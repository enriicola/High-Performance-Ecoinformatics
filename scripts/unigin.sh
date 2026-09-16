#!/usr/bin/env bash

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly PASSWD_FILE="$REPO_ROOT/secrets/unige-gpu2.passwd"
readonly CONNECTION_FILE="$REPO_ROOT/secrets/unige.env"

for secret_file in "$PASSWD_FILE" "$CONNECTION_FILE"; do
  [[ -s "$secret_file" ]] || { echo "Missing credential file: $secret_file" >&2; exit 1; }
done
# Loaded at runtime from a gitignored credential file.
# shellcheck disable=SC1090
source "$CONNECTION_FILE"

for req_var in UNIGE_USERNAME UNIGE_FRONT_HOST; do
  if [[ -z "${!req_var:-}" ]]; then
    echo "Missing $req_var in $CONNECTION_FILE" >&2
    exit 1
  fi
done

exec sshpass -f "$PASSWD_FILE" ssh -tt -o StrictHostKeyChecking=accept-new \
  -o "ProxyCommand=sshpass -f $PASSWD_FILE ssh -o StrictHostKeyChecking=accept-new -W %h:%p $UNIGE_USERNAME@$UNIGE_FRONT_HOST" \
  "$UNIGE_USERNAME@gpu2"

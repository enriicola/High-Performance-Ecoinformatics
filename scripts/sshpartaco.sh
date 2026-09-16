#!/usr/bin/env bash

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly CONNECTION_FILE="$REPO_ROOT/secrets/spartaco.env"
readonly PASSWD_FILE="$REPO_ROOT/secrets/spartaco.passwd"

for credential_file in "$CONNECTION_FILE" "$PASSWD_FILE"; do
  if [[ ! -s "$credential_file" ]]; then
    echo "Missing credential file: $credential_file" >&2
    exit 1
  fi
done

# Loaded at runtime from a gitignored credential file.
# shellcheck disable=SC1090
source "$CONNECTION_FILE"

for req_var in SPARTACO_USERNAME SPARTACO_HOST; do
  if [[ -z "${!req_var:-}" ]]; then
    echo "Missing $req_var in $CONNECTION_FILE" >&2
    exit 1
  fi
done

exec sshpass -f "$PASSWD_FILE" ssh -tt -o StrictHostKeyChecking=accept-new \
  "$SPARTACO_USERNAME@$SPARTACO_HOST"

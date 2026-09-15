#!/usr/bin/env bash

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PASSWD_FILE="$REPO_ROOT/secrets/unige-gpu2.passwd"

exec sshpass -f "$PASSWD_FILE" ssh -tt -o StrictHostKeyChecking=accept-new \
  -o "ProxyCommand=sshpass -f $PASSWD_FILE ssh -o StrictHostKeyChecking=accept-new -W %h:%p REDACTED_USERNAME@REDACTED_HOST" \
  REDACTED_USERNAME@gpu2

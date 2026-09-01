#!/usr/bin/env bash
# Transfer Leonardo output contents to Spartaco through SFTP remotes.
# rclone runs on Serviicola as a relay and does not store the data locally.
# scp -3 is used as a fallback if rclone fails.
set -Eeuo pipefail

readonly LEO_HOST="${LEO_HOST:-REDACTED_USERNAME@login.leonardo.cineca.it}"
readonly LEO_OUTPUT="${LEO_OUTPUT:-/leonardo_work/IscrC_SPECC/data/output}"
readonly SPARTACO_HOST="${SPARTACO_HOST:-user@100.102.164.39}"
readonly SPARTACO_OUTPUT="${SPARTACO_OUTPUT:-F:/HPC_Leonardo}"
readonly LEO_REMOTE="${LEO_REMOTE:-leo}"
readonly SPARTACO_REMOTE="${SPARTACO_REMOTE:-spartaco}"
readonly SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/cineca-agent.sock}"
export SSH_AUTH_SOCK

if (($# == 0)); then
  echo "Transferring all contents of $LEO_OUTPUT ..."
  if ! rclone copyto \
    "$LEO_REMOTE:$LEO_OUTPUT" \
    "$SPARTACO_REMOTE:$SPARTACO_OUTPUT" \
    --progress --stats 30s --stats-one-line; then
    echo "rclone failed; falling back to scp -3 ..."
    scp -3 -r -o ConnectTimeout=20 \
      "$LEO_HOST:$LEO_OUTPUT/." \
      "$SPARTACO_HOST:$SPARTACO_OUTPUT/"
  fi
  echo "Transfer completed."
  exit 0
fi

for path in "$@"; do
  [[ "$path" != /* && "$path" != *..* ]] || {
    echo "Invalid relative path: $path" >&2
    exit 1
  }

  echo "Transferring $path ..."
  if ! rclone copyto \
    "$LEO_REMOTE:$LEO_OUTPUT/$path" \
    "$SPARTACO_REMOTE:$SPARTACO_OUTPUT/$path" \
    --progress --stats 30s --stats-one-line; then
    echo "rclone failed; falling back to scp -3 ..."
    scp -3 -r -o ConnectTimeout=20 \
      "$LEO_HOST:$LEO_OUTPUT/$path" \
      "$SPARTACO_HOST:$SPARTACO_OUTPUT/"
  fi
done

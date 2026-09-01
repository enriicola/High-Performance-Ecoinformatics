#!/usr/bin/env bash
# Transfer Leonardo output contents to Spartaco through SFTP remotes.
# rclone runs on Serviicola as a relay and does not store the data locally.
set -Eeuo pipefail

readonly LEO_OUTPUT="${LEO_OUTPUT:-/leonardo_work/IscrC_SPECC/data/output}"
readonly SPARTACO_OUTPUT="${SPARTACO_OUTPUT:-F:/HPC_Leonardo}"
readonly LEO_REMOTE="${LEO_REMOTE:-leo}"
readonly SPARTACO_REMOTE="${SPARTACO_REMOTE:-spartaco}"
readonly SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/cineca-agent.sock}"
export SSH_AUTH_SOCK

if (($# == 0)); then
  echo "Transferring all contents of $LEO_OUTPUT ..."
  rclone copyto \
    "$LEO_REMOTE:$LEO_OUTPUT" \
    "$SPARTACO_REMOTE:$SPARTACO_OUTPUT" \
    --stats 30s --stats-one-line
  echo "Transfer completed."
  exit 0
fi

for path in "$@"; do
  [[ "$path" != /* && "$path" != *..* ]] || {
    echo "Invalid relative path: $path" >&2
    exit 1
  }

  echo "Transferring $path ..."
  rclone copyto \
    "$LEO_REMOTE:$LEO_OUTPUT/$path" \
    "$SPARTACO_REMOTE:$SPARTACO_OUTPUT/$path" \
    --stats 30s --stats-one-line
done

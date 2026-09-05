#!/usr/bin/env bash
# Copy heavy runtime data from Leonardo to the matching paths on Spartaco.
# Serviicola relays the transfer without storing an intermediate copy.
# Usage: ./scripts/3sync.sh [relative-path ...]
# With no path, data and container/geospatial.sif are synchronized.
set -Eeuo pipefail

readonly LEO_HOST="REDACTED_USERNAME@login.leonardo.cineca.it"
readonly LEO_ROOT="/leonardo_work/IscrC_SPECC"
readonly SPARTACO_HOST="user@100.102.164.39"
readonly SPARTACO_ROOT="F:/HPC_Leonardo"
readonly LEO_REMOTE="leo"
readonly SPARTACO_REMOTE="spartaco"
readonly SSH_AUTH_SOCK="$HOME/.ssh/cineca-agent.sock"
export SSH_AUTH_SOCK

if (($# == 0)); then
  set -- data container/geospatial.sif
fi

for path in "$@"; do
  [[ "$path" != /* && "$path" != *..* ]] || {
    echo "Invalid relative path: $path" >&2
    exit 1
  }

  echo "Transferring $path ..."
  if ! rclone copyto \
    "$LEO_REMOTE:$LEO_ROOT/$path" \
    "$SPARTACO_REMOTE:$SPARTACO_ROOT/$path" \
    --progress --stats 30s --stats-one-line; then
    echo "rclone failed; falling back to scp -3 ..."
    destination_parent="$SPARTACO_ROOT"
    [[ "$path" == */* ]] && destination_parent="$SPARTACO_ROOT/${path%/*}"
    scp -3 -r -o ConnectTimeout=20 \
      "$LEO_HOST:$LEO_ROOT/$path" \
      "$SPARTACO_HOST:$destination_parent/"
  fi
done

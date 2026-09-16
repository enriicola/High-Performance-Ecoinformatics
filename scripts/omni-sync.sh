#!/usr/bin/env bash
# Copy heavy runtime data from Leonardo to the matching paths on Spartaco.
# Serviicola relays the transfer without storing an intermediate copy.
# Usage: ./scripts/omni-sync.sh [relative-path ...]
# With no path, data and container/geospatial.sif are synchronized.
set -Eeuo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly CINECA_CONNECTION_FILE="$REPO_ROOT/secrets/cineca.env"
readonly SPARTACO_CONNECTION_FILE="$REPO_ROOT/secrets/spartaco.env"

for connection_file in "$CINECA_CONNECTION_FILE" "$SPARTACO_CONNECTION_FILE"; do
  [[ -s "$connection_file" ]] || { echo "Missing credential file: $connection_file" >&2; exit 1; }
done
# Loaded at runtime from gitignored credential files.
# shellcheck disable=SC1090
source "$CINECA_CONNECTION_FILE"
# shellcheck disable=SC1090
source "$SPARTACO_CONNECTION_FILE"

for req_var in CINECA_USERNAME CINECA_HOST SPARTACO_USERNAME SPARTACO_HOST; do
  if [[ -z "${!req_var:-}" ]]; then
    echo "Missing $req_var in credential files" >&2
    exit 1
  fi
done

readonly LEO_HOST="$CINECA_USERNAME@$CINECA_HOST"
readonly LEO_ROOT="/leonardo_work/IscrC_SPECC"
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
    # SPARTACO_HOST is loaded and validated above.
    # shellcheck disable=SC2153
    scp -3 -r -o ConnectTimeout=20 \
      "$LEO_HOST:$LEO_ROOT/$path" \
      "$SPARTACO_USERNAME@$SPARTACO_HOST:$destination_parent/"
  fi
done

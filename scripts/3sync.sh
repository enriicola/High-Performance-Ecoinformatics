#!/usr/bin/env bash
# Transfer completed BIOMOD outputs from Leonardo to Spartaco.
# scp -3 uses Serviicola as a relay and does not store the data locally.
set -Eeuo pipefail

readonly LEO_HOST="${LEO_HOST:-REDACTED_USERNAME@login.leonardo.cineca.it}"
readonly LEO_OUTPUT="${LEO_OUTPUT:-/leonardo_work/IscrC_SPECC/data/output_campaign_pa10}"
readonly SPARTACO_HOST="${SPARTACO_HOST:-user@100.102.164.39}"
readonly SPARTACO_OUTPUT="${SPARTACO_OUTPUT:-F:/HPC_Leonardo}"
readonly SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/cineca-agent.sock}"
export SSH_AUTH_SOCK

if (($#)); then
  species=("$@")
else
  mapfile -t species < <(
    ssh -o ConnectTimeout=20 "$LEO_HOST" \
      "find '$LEO_OUTPUT' -mindepth 2 -maxdepth 2 -type f -name _SUCCESS -printf '%h\\n' | sed 's#^$LEO_OUTPUT/##' | sort"
  )
fi

if ((${#species[@]} == 0)); then
  echo "No completed species found under $LEO_OUTPUT."
  exit 0
fi

for name in "${species[@]}"; do
  [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || {
    echo "Invalid species name: $name" >&2
    exit 1
  }

  source="$LEO_OUTPUT/$name"
  target="$SPARTACO_OUTPUT/$name"
  marker="$target/._3sync_complete"

  ssh -o ConnectTimeout=20 "$LEO_HOST" "test -f '$source/_SUCCESS'" || {
    echo "Skipping $name: source has no _SUCCESS."
    continue
  }

  if ssh -o ConnectTimeout=20 "$SPARTACO_HOST" "if exist \"$marker\" exit /b 0"; then
    echo "Skipping $name: already transferred."
    continue
  fi

  if ssh -o ConnectTimeout=20 "$SPARTACO_HOST" "if exist \"$target\" exit /b 0"; then
    echo "Refusing $name: destination exists without completion marker: $target" >&2
    exit 1
  fi

  echo "Transferring $name ..."
  scp -3 -r -o ConnectTimeout=20 \
    "$LEO_HOST:$source" \
    "$SPARTACO_HOST:$SPARTACO_OUTPUT/"

  ssh -o ConnectTimeout=20 "$SPARTACO_HOST" "type nul > \"$marker\""
  echo "Completed $name."
done

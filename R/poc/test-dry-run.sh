#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

expect_output() {
  local expected=$1
  shift
  local output
  output=$(env -u SLURM_CPUS_PER_TASK "$@")
  if ! grep -Fq "$expected" <<< "$output"; then
    printf 'Expected dry-run output to contain: %s\n' "$expected" >&2
    exit 1
  fi
}

expect_output '"sequential_io_sequential_models"' \
  "$ROOT/R/poc/run-sequential-io-sequential-models.sh" --dry-run --run-id=test-seq
expect_output '"sequential_io_parallel_models"' \
  "$ROOT/R/poc/run-sequential-io-parallel-models.sh" --dry-run --run-id=test-models
expect_output '"parallel_io_parallel_models"' \
  "$ROOT/R/poc/run-parallel-io-parallel-models.sh" --dry-run --run-id=test-io
expect_output '"io-sequential_models-sequential_species-snowfall"' \
  Rscript "$ROOT/R/poc/main.R" --sequential --snowfall --species=1,2 --dry-run
expect_output '"io-parallel_models-sequential_species-direct"' \
  Rscript "$ROOT/R/poc/main.R" --io=parallel --models=sequential --dry-run

error_log=$(mktemp)
trap 'rm -f "$error_log"' EXIT
if SLURM_CPUS_PER_TASK=2 Rscript "$ROOT/R/poc/main.R" \
  --parallel --model-workers=4 --dry-run > "$error_log" 2>&1; then
  echo "Oversubscribed profile was accepted" >&2
  exit 1
fi
grep -Fq 'exceeds SLURM_CPUS_PER_TASK=2' "$error_log"

printf 'POC dry-run checks passed\n'

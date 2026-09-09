#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
exec Rscript "$ROOT/R/poc/main.R" \
  "--config=$ROOT/R/poc/config.R" \
  --variant=sequential_io_sequential_models \
  "$@"

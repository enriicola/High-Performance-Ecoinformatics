#!/usr/bin/env bash
# Run inside one exclusive Slurm allocation on Leonardo.
set -euo pipefail

if [[ -z "${SLURM_JOB_ID:-}" ]]; then
  echo "Run this script inside an srun/salloc allocation." >&2
  exit 2
fi

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

IMAGE="$ROOT/container/geospatial.sif"
RESULTS_DIR="$ROOT/logs/benchmark_split_vs_monolith_${SLURM_JOB_ID}"
RUN_ORDER=(split monolith monolith split split monolith monolith split split monolith)

mkdir -p "$RESULTS_DIR"
printf 'run\tversion\tnode\tstarted_at\tfinished_at\texit_code\ttime_maxrss_kb\n' > "$RESULTS_DIR/summary.tsv"

run_case() {
  local run_number=$1
  local version=$2
  local output_dir="data/benchmark_${SLURM_JOB_ID}_${run_number}_${version}"
  local output_in_container="/work/$output_dir"
  local log="$RESULTS_DIR/${run_number}_${version}.log"
  local rss="$RESULTS_DIR/${run_number}_${version}_rss.tsv"
  local script

  if [[ "$version" == "split" ]]; then
    script="/work/R/separation-test_risolto/main.R"
  else
    script="/work/R/small.test_risolto.R"
  fi

  rm -rf "$output_dir"
  printf 'timestamp\tpid\trss_kb\tvsz_kb\tcommand\n' > "$rss"

  local started_at finished_at runner exit_code maxrss
  started_at=$(date -Is)
  (
    env INPUT_CSV=small_1km_EUNIS.csv \
      PA_NB_REP=1 \
      PA_NB_ABSENCES=10 \
      CV_NB_REP=1 \
      FUTURE_LIMIT=0 \
      FINAL_SLEEP_SECONDS=0 \
      R_SEED=42 \
      R_DEBUG_ECHO=false \
      OMP_NUM_THREADS=1 \
      OUTPUT_DIR="$output_in_container" \
      /usr/bin/time -v singularity exec --pwd /work --bind "$ROOT:/work" "$IMAGE" \
        Rscript "$script"
  ) > "$log" 2>&1 &
  runner=$!

  while kill -0 "$runner" 2>/dev/null; do
    { ps -C R -o pid=,rss=,vsz=,comm= 2>/dev/null || true; } \
      | awk -v timestamp="$(date -Is)" 'NF { print timestamp "\t" $1 "\t" $2 "\t" $3 "\t" $4 }' \
      >> "$rss"
    sleep 1
  done

  if wait "$runner"; then
    exit_code=0
  else
    exit_code=$?
  fi
  finished_at=$(date -Is)
  maxrss=$(awk -F: '/Maximum resident set size/ { gsub(/^[[:space:]]+/, "", $2); print $2 }' "$log")

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$run_number" "$version" "${SLURMD_NODENAME:-$(hostname)}" "$started_at" "$finished_at" "$exit_code" "$maxrss" \
    >> "$RESULTS_DIR/summary.tsv"

  if [[ "$exit_code" -ne 0 ]]; then
    echo "Run $run_number ($version) failed; preserving $output_dir" >&2
    return "$exit_code"
  fi

  cp "$output_dir/time_Achillea.atrata.txt" "$RESULTS_DIR/${run_number}_${version}_phases.tsv"
  rm -rf "$output_dir"
}

for index in "${!RUN_ORDER[@]}"; do
  run_case "$((index + 1))" "${RUN_ORDER[index]}"
done

#!/bin/bash
set -euxo pipefail

cd "$(dirname "$0")/.."

git pull
git lfs pull

JOBID=$(sbatch scripts/sbatch.sh 2>&1 | grep -oP 'Submitted batch job \K\d+')
LOG="job_${JOBID}.log"

# Wait for output file to appear
while [[ ! -f "$LOG" ]] && squeue -j "$JOBID" &>/dev/null; do
    sleep 2
done

# Stream logs in background while job runs
tail -f "$LOG" &
TAIL_PID=$!

# Wait for job completion
while squeue -j "$JOBID" 2>/dev/null | grep -q "$JOBID"; do
    sleep 10
done

kill "$TAIL_PID" 2>/dev/null || true

# Commit results if any changes
git add -A data/output/ "$LOG" 2>/dev/null || true
if ! git diff --cached --quiet; then
    git commit -m "results: job $JOBID"
    git push
fi

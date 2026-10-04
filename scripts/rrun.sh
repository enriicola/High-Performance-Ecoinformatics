#!/usr/bin/env bash
set -Eeuo pipefail

echo "TODO: to be implemented"
exit 0
# these script will be used with 'make rrun'
# it'll help automatize the process of executing a given Rscript
# from a given apptainer/singularity container

readonly script_root="tmp"
readonly IMAGE="$REPO_ROOT/container/geospatial.sif"
readonly RSCRIPT_PATH="for argument"
readonly JOB_LABEL="${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:-local}}_${SLURM_ARRAY_TASK_ID:-0}"
readonly RESOURCE_LOG="$REPO_ROOT/logs/resources_${JOB_LABEL}.txt"

cd "$REPO_ROOT"
mkdir -p data/output logs

# Prevent nested BLAS/OpenMP threads inside each biomod2 worker.
readonly OMP_NUM_THREADS=1
readonly OPENBLAS_NUM_THREADS=1
readonly MKL_NUM_THREADS=1
export OMP_NUM_THREADS OPENBLAS_NUM_THREADS MKL_NUM_THREADS

printf 'Job: id=%s array_task=%s node=%s\n' \
  "${SLURM_JOB_ID:-local}" \
  "${SLURM_ARRAY_TASK_ID:-none}" \
  "${SLURMD_NODENAME:-$(hostname)}"
printf 'Resources: cpus=%s memory=all-node\n' \
  "${SLURM_CPUS_PER_TASK:-unknown}"
printf 'R script: %s\n' "$RSCRIPT_PATH"
printf 'Started: %s\n' "$(date -Is)"
printf 'Resource log: %s\n' "$RESOURCE_LOG"

readonly started_at=$SECONDS
if /usr/bin/time -v -o "$RESOURCE_LOG" singularity exec \
  --pwd /work \
  --bind "$REPO_ROOT:/work" \
  "$IMAGE" \
  Rscript "$RSCRIPT_PATH" 2>&1 \
  | gawk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush() }'
then
  exit_code=0
else
  exit_code=$?
fi
readonly elapsed=$((SECONDS - started_at))

printf 'Finished: %s\n' "$(date -Is)"
printf 'Elapsed: %dd %dh %dm %ds\n' \
  $((elapsed / 86400)) \
  $((elapsed % 86400 / 3600)) \
  $((elapsed % 3600 / 60)) \
  $((elapsed % 60))

exit "$exit_code"

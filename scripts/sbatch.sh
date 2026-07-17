#!/usr/bin/env bash
#SBATCH --job-name=biomod_species
#SBATCH --account=IscrC_SPECC
#SBATCH --partition=dcgp_usr_prod
#SBATCH --qos=dcgp_qos_lprod

# One isolated DCGP node per species task.
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --time=4-00:00:00

#SBATCH --output=logs/job_%A_%a.log
#SBATCH --error=logs/job_%A_%a.log
#SBATCH --mail-type=END,FAIL,TIME_LIMIT,ARRAY_TASKS

set -Eeuo pipefail

readonly REPO_ROOT="${SLURM_SUBMIT_DIR:-$PWD}"
readonly IMAGE="$REPO_ROOT/container/geospatial.sif"
readonly RSCRIPT_PATH="${RSCRIPT_PATH:-/work/R/base_sequential_analysis.R}"
readonly JOB_LABEL="${SLURM_ARRAY_JOB_ID:-${SLURM_JOB_ID:-local}}_${SLURM_ARRAY_TASK_ID:-0}"
readonly RESOURCE_LOG="$REPO_ROOT/logs/resources_${JOB_LABEL}.txt"

cd "$REPO_ROOT"
mkdir -p data/output logs

# Prevent nested BLAS/OpenMP threads inside each biomod2 worker.
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

printf 'Job: id=%s array_task=%s node=%s\n' \
  "${SLURM_JOB_ID:-local}" \
  "${SLURM_ARRAY_TASK_ID:-none}" \
  "${SLURMD_NODENAME:-$(hostname)}"
printf 'Resources: cpus=%s memory=all-node\n' \
  "${SLURM_CPUS_PER_TASK:-unknown}"
printf 'R script: %s\n' "$RSCRIPT_PATH"
printf 'Started: %s\n' "$(date -Is)"
printf 'Resource log: %s\n' "$RESOURCE_LOG"

started_at=$SECONDS
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
elapsed=$((SECONDS - started_at))

printf 'Finished: %s\n' "$(date -Is)"
printf 'Elapsed: %dd %dh %dm %ds\n' \
  $((elapsed / 86400)) \
  $((elapsed % 86400 / 3600)) \
  $((elapsed % 3600 / 60)) \
  $((elapsed % 60))

exit "$exit_code"

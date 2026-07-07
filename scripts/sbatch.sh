#!/bin/bash
#SBATCH --job-name=r_singularity
#SBATCH --account=IscrC_SPECC
#SBATCH --array=1-5
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=250G
#SBATCH --partition=dcgp_usr_prod
#SBATCH --qos=dcgp_qos_lprod
#SBATCH --time=72:00:00
#SBATCH --output=logs/job_%A_%a.log
#SBATCH --error=logs/job_%A_%a.log
#SBATCH --mail-type=END,FAIL,REQUEUE,TIME_LIMIT
#SBATCH --mail-user=$USER
# TODO send mail to current logged user, not hardcoded

set -xo pipefail

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# runtime toggles (override at submission with --export)
RSCRIPT_PATH=${RSCRIPT_PATH:-/work/R/fast.test_risolto.R}
R_DEBUG_ECHO=${R_DEBUG_ECHO:-false}
FORCE_CLEAN=${FORCE_CLEAN:-false}
FORCE_REBUILD_FUTURE=${FORCE_REBUILD_FUTURE:-false}
PROJ_KEEP_IN_MEMORY=${PROJ_KEEP_IN_MEMORY:-false}
PROJ_DO_STACK=${PROJ_DO_STACK:-false}
TERRA_MEMFRAC=${TERRA_MEMFRAC:-0.7}

echo "CONFIG: RSCRIPT_PATH=$RSCRIPT_PATH"
echo "CONFIG: R_DEBUG_ECHO=$R_DEBUG_ECHO FORCE_CLEAN=$FORCE_CLEAN FORCE_REBUILD_FUTURE=$FORCE_REBUILD_FUTURE"
echo "CONFIG: PROJ_KEEP_IN_MEMORY=$PROJ_KEEP_IN_MEMORY PROJ_DO_STACK=$PROJ_DO_STACK TERRA_MEMFRAC=$TERRA_MEMFRAC"

# array-safe: each task wipes only its own species dir (done in R), not the whole tree.
mkdir -p data/output logs

# pipe through gawk strftime -> every log line gets a wall-clock stamp (live, fflush).
# runs on the host outside the container, so host gawk is used (no moreutils `ts` needed).
T_START=$SECONDS
singularity exec --pwd /work --bind $PWD:/work $PWD/container/geospatial.sif \
  env R_DEBUG_ECHO="$R_DEBUG_ECHO" \
      FORCE_CLEAN="$FORCE_CLEAN" \
      FORCE_REBUILD_FUTURE="$FORCE_REBUILD_FUTURE" \
      PROJ_KEEP_IN_MEMORY="$PROJ_KEEP_IN_MEMORY" \
      PROJ_DO_STACK="$PROJ_DO_STACK" \
      TERRA_MEMFRAC="$TERRA_MEMFRAC" \
      OMP_NUM_THREADS="$OMP_NUM_THREADS" \
  Rscript "$RSCRIPT_PATH" 2>&1 \
  | gawk '{ print strftime("[%H:%M:%S]"), $0; fflush() }'
EXIT_CODE=$?
T_ELAPSED=$(( SECONDS - T_START ))
printf "Elapsed: %dd %dh %dm %ds\n" \
  $(( T_ELAPSED/86400 )) $(( T_ELAPSED%86400/3600 )) $(( T_ELAPSED%3600/60 )) $(( T_ELAPSED%60 ))
exit "$EXIT_CODE"

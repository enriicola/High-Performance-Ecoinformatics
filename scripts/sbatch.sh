#!/bin/bash
#SBATCH --job-name=r_singularity
#SBATCH --account=IscrC_SPECC
#SBATCH --array=1-3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
#SBATCH --mem=0
#SBATCH --partition=dcgp_usr_prod
#SBATCH --qos=dcgp_qos_lprod
#SBATCH --time=72:00:00
#SBATCH --output=logs/job_%A_%a.log
#SBATCH --error=logs/job_%A_%a.log
#SBATCH --mail-type=END,FAIL,REQUEUE,TIME_LIMIT

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# array-safe: each task wipes only its own species dir (done in R), not the whole tree.
mkdir -p data/output logs

# pipe through gawk strftime -> every log line gets a wall-clock stamp (live, fflush).
# runs on the host outside the container, so host gawk is used (no moreutils `ts` needed).
time singularity exec --pwd /work --bind $PWD:/work $PWD/container/geospatial.sif Rscript "/work/R/test_risolto.R" 2>&1 \
  | gawk '{ print strftime("[%H:%M:%S]"), $0; fflush() }'

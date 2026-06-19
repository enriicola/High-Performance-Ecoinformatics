#!/bin/bash
#SBATCH --job-name=r_singularity
#SBATCH --account=IscrC_SPECC
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
#SBATCH --mem=0
#SBATCH --partition=dcgp_usr_prod
#SBATCH --qos=dcgp_qos_lprod
#SBATCH --time=72:00:00
#SBATCH --output=job.log
#SBATCH --error=job.log
#SBATCH --mail-type=END,FAIL,REQUEUE,TIME_LIMIT

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# wipe previous run outputs before each run (keep the committed reference file). R recreates the dir.
mkdir -p data/output
find data/output -mindepth 1 ! -name 'expected_output_foreach_species.txt' -delete

# pipe through gawk strftime -> every log line gets a wall-clock stamp (live, fflush).
# runs on the host outside the container, so host gawk is used (no moreutils `ts` needed).
time singularity exec --pwd /work --bind $PWD:/work $PWD/container/geospatial.sif Rscript "/work/R/test_risolto.R" 2>&1 \
  | gawk '{ print strftime("[%H:%M:%S]"), $0; fflush() }'

#!/bin/bash
#SBATCH --job-name=r_singularity
#SBATCH --account=IscrC_SPECC
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
#SBATCH --partition=dcgp_usr_prod
#SBATCH --time=02:00:00
#SBATCH --output=job.out
#SBATCH --error=job.err

cd $WORK
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

START_HOUR=$(date +"%H")
START_MINUTE=$(date +"%M")
echo "Starting job at $(date)"

singularity exec --bind $PWD:/work $PWD/containers/geospatial.sif Rscript /work/main.r

echo "Job finished at $(date)"
FINISH_HOUR=$(date +"%H")
FINISH_MINUTE=$(date +"%M")
echo "Job completed in $(($FINISH_HOUR - $START_HOUR)) hours and $(($FINISH_MINUTE - $START_MINUTE)) minutes."
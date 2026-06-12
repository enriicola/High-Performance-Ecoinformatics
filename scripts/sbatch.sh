#!/bin/bash
#SBATCH --job-name=r_singularity
#SBATCH --account=IscrC_SPECC
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=56
#SBATCH --partition=dcgp_usr_prod
#SBATCH --qos=dcgp_qos_lprod
#SBATCH --time=12:00:00
#SBATCH --output=job_%j.log
#SBATCH --error=job_%j.log
#SBATCH --mail-type=ALL

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

time singularity exec --pwd /work --bind $PWD:/work $PWD/container/geospatial.sif Rscript "/work/r/new.ensamble_modelling.R"

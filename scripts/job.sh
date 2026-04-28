#!/bin/bash
#SBATCH --job-name=biomod_sim
#SBATCH --output=biomod_%j.out
#SBATCH --error=biomod_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --partition=dcgp_usr_prod
#SBATCH --account=<YOUR_ACCOUNT_ID>

echo "Starting BIOMOD simulation at $(date)"

# Load Apptainer module (usually pre-installed, but good practice)
module load apptainer

# Run the container and execute the simulation script
apptainer run --bind .:/data container.sif Rscript simulation.r

echo "Simulation finished at $(date)"

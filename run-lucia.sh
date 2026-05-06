#!/bin/bash
#SBATCH --job-name=lucia
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

singularity exec --bind $PWD:/work $PWD/containers/geospatial.sif Rscript /work/main.r

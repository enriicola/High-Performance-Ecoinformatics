#!/bin/bash
singularity exec --bind $PWD:/work $PWD/containers/geospatial.sif Rscript /work/main.r

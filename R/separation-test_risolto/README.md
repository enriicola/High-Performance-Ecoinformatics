# separation-test_risolto

Split version of `R/test_risolto.R`.

## Run with defaults

```bash
singularity exec --pwd /work --bind $PWD:/work $PWD/container/geospatial.sif \
  Rscript /work/R/separation-test_risolto/main.R
```

## PA=10 benchmark-style run

```bash
singularity exec --pwd /work --bind $PWD:/work $PWD/container/geospatial.sif \
  env INPUT_CSV=agrostis_1km_EUNIS.csv \
      PA_NB_REP=3 \
      PA_NB_ABSENCES=10 \
      CV_NB_REP=2 \
      SPECIES_INDEX=1 \
      OUTPUT_DIR=/work/data/output_split_pa10 \
  Rscript /work/R/separation-test_risolto/main.R
```

## sbatch benchmark-style run

```bash
sbatch --export=ALL,RSCRIPT_PATH=/work/R/separation-test_risolto/main.R,INPUT_CSV=agrostis_1km_EUNIS.csv,PA_NB_REP=3,PA_NB_ABSENCES=10,CV_NB_REP=2,SPECIES_INDEX=1,OUTPUT_DIR=/work/data/output_split_pa10 scripts/sbatch.sh
```

## Optional env vars

- `INPUT_CSV` (default: `full_1km_EUNIS.csv`)
- `PA_NB_REP` (default: `10`)
- `PA_NB_ABSENCES` (default: `10000`)
- `CV_NB_REP` (default: `5`)
- `SPECIES_INDEX` (default: `SLURM_ARRAY_TASK_ID` or `1`)
- `OUTPUT_DIR` (default: `data/output`)
- `FUTURE_LIMIT` (default: all futures)
- `FINAL_SLEEP_SECONDS` (default: `10`)
# Data storage

The contents of `data/input/` and generated files under `data/output/` are intentionally excluded from Git. Input data totals several gigabytes and most source rasters exceed GitHub's 100 MB file limit; BIOMOD2 output is substantially larger. Small summary files matching `data/output/*.txt` remain versioned.

- Leonardo working data: `/leonardo_work/IscrC_SPECC/data/`
- Spartaco archive: `F:\HPC_Leonardo\`
- Serviicola: transfer relay and local working copy of the input data

`scripts/3sync.sh` copies paths relative to `data/` from Leonardo to the same relative paths on Spartaco:

```bash
./scripts/3sync.sh input
./scripts/3sync.sh output
./scripts/3sync.sh output_campaign_pa10
```

Running it without arguments synchronizes all of `data/`. The script copies files but does not delete destination files. The existing species directories stored directly in `F:\HPC_Leonardo\` predate this mirrored layout.

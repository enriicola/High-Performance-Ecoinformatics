# Data storage

Large files under `data/input/` and generated files under `data/output/` are intentionally excluded from Git. Input data totals several gigabytes and most source rasters exceed GitHub's 100 MB file limit; BIOMOD2 output is substantially larger. Git keeps the two small input CSV files and summary files matching `data/output/*.txt`.

- Leonardo repository: `/leonardo_work/IscrC_SPECC/`, with heavy data under `data/`
- Spartaco repository: `F:\HPC_Leonardo\`, with heavy data under `data\`
- Serviicola: Git checkout and transfer relay, without heavy data

`scripts/3sync.sh` copies paths relative to Leonardo's `data/` into `F:\HPC_Leonardo\data\` on Spartaco:

```bash
./scripts/3sync.sh input
./scripts/3sync.sh output
./scripts/3sync.sh output_campaign_pa10
```

Running it without arguments synchronizes all of `data/`. The script copies files but does not delete destination files.

## Directory layout

Large production inputs are kept on Leonardo/Spartaco and are not kept in this checkout. The expected input layout is:

```text
data/input
├── agrostis_1km_EUNIS.csv
├── climate_vars
│   ├── baseline
│   │   ├── PC1.tif
│   │   └── PC2.tif
│   └── future
│       ├── gfdl.esm4
│       │   ├── ssp370
│       │   │   ├── PC1.tif
│       │   │   └── PC2.tif
│       │   └── ssp585
│       │       ├── PC1.tif
│       │       └── PC2.tif
│       ├── ipsl.cm6a.lr
│       │   ├── ssp370
│       │   │   ├── PC1.tif
│       │   │   └── PC2.tif
│       │   └── ssp585
│       │       ├── PC1.tif
│       │       └── PC2.tif
│       ├── mpi.esm1.2.hr
│       │   ├── ssp370
│       │   │   ├── PC1.tif
│       │   │   └── PC2.tif
│       │   └── ssp585
│       │       ├── PC1.tif
│       │       └── PC2.tif
│       └── mri.esm2.0
│           ├── ssp370
│           │   ├── PC1.tif
│           │   └── PC2.tif
│           └── ssp585
│               ├── PC1.tif
│               └── PC2.tif
├── full_1km_EUNIS.csv
├── small_1km_EUNIS.csv
├── soil_vars
│   ├── PC1_Edaphic.tif
│   └── PC2_Edaphic.tif
└── TRI_vars
    └── TRI.tif
```

The complete expected single-species output tree is recorded in [`../tests/expected_output_foreach_species.txt`](../tests/expected_output_foreach_species.txt). A top-level tree verified against Leonardo is:

```text
data/output
├── Eval_<species>.txt
├── Eval_EM_<species>.txt
├── time_<species>.txt
├── time_future_<species>.txt
└── <species>
    ├── <species>.<id>.models.out
    ├── <species>.<id>.ensemble.models.out
    ├── models
    ├── proj_current
    ├── proj_CurrentEM
    ├── proj_<gcm>_<ssp>
    └── proj_futureEM_<gcm>_<ssp>
```

Only the `.txt` files written directly under `data/output/` are versioned.

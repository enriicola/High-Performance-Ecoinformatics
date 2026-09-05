# Data storage

Large files under `data/input/` and generated files under `data/output/` are intentionally excluded from Git. Input data totals several gigabytes and most source rasters exceed GitHub's 100 MB file limit; BIOMOD2 output is substantially larger. Git keeps the two small input CSV files and summary files matching `data/output/*.txt`.

The Git repository and `container/geospatial.sif` are kept on all three computers. The container is ignored by Git.

- Leonardo: `/leonardo_work/IscrC_SPECC/`, with the container and heavy data under `data/`
- Spartaco: `F:\HPC_Leonardo\`, with the container and a copy of the heavy data under `data\`
- Serviicola: `/home/ubuntu/tesi/`, with the container but without a copy of the heavy data

`scripts/3sync.sh` copies heavy data and `container/geospatial.sif` from Leonardo to the same relative paths on Spartaco, using Serviicola as the transfer relay:

```bash
./scripts/3sync.sh data/input
./scripts/3sync.sh data/output
./scripts/3sync.sh data/output_campaign_pa10
./scripts/3sync.sh container/geospatial.sif
```

Running it without arguments copies `data/` and `container/geospatial.sif` from Leonardo to Spartaco. Serviicola keeps its own copy of the container but does not retain an intermediate copy of the transferred data. The script does not delete destination files.

## Directory layout

Large production inputs are kept on Leonardo and Spartaco, not on Serviicola. The expected input layout is:

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

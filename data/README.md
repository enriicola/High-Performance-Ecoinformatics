# Data storage

Large files under `data/input/`, generated heavy .tif files under `data/output/`, and the .sif container image are intentionally excluded from Git. 

All the computers and the heavy data are synced via `scripts/omni-sync.sh`, called from the Makefile with:

```bash
make omni-sync
```

## Directory layout

The expected input layout is:

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

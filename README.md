# High Performance Ecoinformatics: Master's Thesis Project

## 📋 Task Tracking & TODOs

### Active Tasks & Backlog
- [ ] gemini --resume 6138a5bd-a73b-4fe4-a636-8840895cb730
- [ ] move workspace to leo cineca by copyng input/ and the container via scp and cloning the git repo inside my userdb workspace and using vscode extension to ssh into leo cineca

- [ ] Refinement of `simulation.r` for performance optimization.
- [ ] Integration of topographic roughness index (TRI) layers.
- [ ] Validation of PCA future scenario projections.
- [ ] Full HPC run on Cineca Leonardo.
- [ ] Metric extraction (TSS, AUC, etc.) and visualization.
- [ ] Thesis document (`thesis.tex`) finalization.

### Operative TODOs
- [x] baseline == presente ???
- [ ] rename gh repo from biomod++ to 'high performance ecoinformatics'
- [ ] entrare on omarchy nella vpn forticlient
- [ ] entrare con serviicola nella vpn forticlient
- [ ] abilitare ssh su spartaco
- [ ] copy stuff from spartaco using scp and not remmina
- [ ] connect to cineca from my linux
- [ ] redirect all prints of .def file to null, except errors and warnings
- [ ] apptainer run --bind $WORK:/work,$CINECA_SCRATCH:/scratch biomod++.sif
- [ ] use rocker image with CUDA support <https://rocker-project.org/images/versioned/cuda.html>
- [ ] add sonarcube bind and support

---

## Abstract / Project Overview
This repository contains the codebase and notes for my Master of Science thesis project, focusing on High-Performance Ecoinformatics. The goal is to perform ensemble species distribution modelling using the `biomod2` pipeline on HPC environments (Cineca Leonardo).

## Project Status & Notes
- **Current Phase**: Implementation & Local Validation.
- **Goal**: Finalizing the ensemble modelling pipeline for the Master's thesis.
- **Core Context**:
  - **Technologies**: R (`biomod2`, `terra`), Apptainer, SLURM (Cineca Leonardo).
  - **Environment**: Containerized execution (`container.sif`) is mandatory for consistency.
- **Known Issues / Technical Notes**:
  - Always use `TEST_N_ROWS` for local debugging to avoid long execution times.
  - Ensure `make.names()` is used for all layer names in formulas.

---

## 📖 Thesis Notes

### 1. Ecological and Environmental Data

#### Target Species and Occurrences
- **Study System**: Alpine grasslands.
- **Occurrence Data**: `data_62768_rows` (formerly `data_1km_eunis.txt`). This dataset contains presence/absence points of the target species, mapped at a 1 km² resolution.

#### Predictor Variables (Environmental & Climatic)
The model leverages raster data representing climatic and soil variables. To reduce dimensionality and collinearity, a **Principal Component Analysis (PCA)** has been applied to these variables.

**Timeframes & Scenarios:**
- **Baseline**: Present-day climate and soil variables.
- **Future Projections**:
  - **SSP3-7.0**: Intermediate/high greenhouse gas emissions scenario.
  - **SSP5-8.5**: Pessimistic/worst-case greenhouse gas emissions scenario.

### 2. Methodology & Software Stack

#### R Packages for Spatial Analysis
- **`terra` & `sf`**: Core libraries used for handling, processing, and projecting spatial raster and vector data.
- **`biomod2`**: The primary framework for building ensemble species distribution models (SDMs).

#### Ensemble Algorithms
*(To be detailed based on implementation)*
- **Expected algorithms to evaluate**: GLM (Generalized Linear Models), GBM (Gradient Boosting Machines), RF (Random Forest), MaxEnt.

#### System Dependencies
The R packages rely on high-performance C++ system libraries. These must be installed via the system package manager (`apt` on Debian/Ubuntu) prior to R package compilation. (See `containers/installation` for the centralized list).

- **Core Geospatial Stack**:
  - **GDAL (`libgdal-dev`)**: The "Translator." Handles reading, writing, and compressing raster files (e.g., `.tif`).
  - **PROJ (`libproj-dev`)**: The "Map Maker." Manages coordinate reference systems (CRS) and map projections.
  - **GEOS (`libgeos-dev`)**: The "Geometry Engine." Performs spatial logic.
- **Supporting Libraries**:
  - **udunits2 (`libudunits2-dev`)**: Handles physical unit conversions.
  - **libsodium (`libsodium-dev`)**: Provides modern cryptography and security.

### 3. High-Performance Computing (Cineca Leonardo)

The computational core of this thesis runs on the Cineca Leonardo supercomputer using Apptainer containers to ensure reproducibility.

#### Access via Step SSH
To authenticate and access the Cineca cluster securely:

```bash
if [ -f ~/.bash_agent ]; then
    . ~/.bash_agent
fi

steptest=$(step ssh list --raw '<USER_EMAIL>'| step ssh inspect | grep "Valid")

if [ -z "$steptest" ]; then
    eval $(ssh-agent)
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > ~/.bash_agent
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> ~/.bash_agent
    step ssh login '<USER_EMAIL>' --provisioner cineca-hpc
fi
```

### 4. Planned Analyses & Future Work
- **Results Extraction**: Extraction and visualization of model evaluation metrics (TSS, ROC/AUC, etc.).
- **Hotspot Analysis**: Identification of climate refugia or areas of high vulnerability for the target species.
- **Improvements**: ...

---

## References and Bookmarks
- [biomod2 Reference Manual](https://cran.r-project.org/web/packages/biomod2/refman/biomod2.html)
- [biomod2 GitHub Pages](https://biomodhub.github.io/biomod2/)
- [CausalGPS Singularity Vignette](https://cran.r-project.org/web/packages/CausalGPS/vignettes/Singularity-Image.html)
- [Cineca HPC Singularity Docs](https://docs.hpc.cineca.it/services/singularity.html)
- [Cineca HPC Getting Started](https://docs.hpc.cineca.it/general/getting_started.html)
- [Access to the Systems](https://docs.hpc.cineca.it/general/access.html#access-to-the-systems)
- [Manage your HPC credentials](https://docs.hpc.cineca.it/general/users_account.html#manage-your-hpc-credentials)
- [How to manage authentication certificates](https://docs.hpc.cineca.it/general/access.html#how-to-mnage-authtentication-certificates)
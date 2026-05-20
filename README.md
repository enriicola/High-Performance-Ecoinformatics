# High Performance Ecoinformatics: Master's Thesis Project

## 📋 Task Tracking & TODOs

### Active Tasks & Backlog
- [ ] verify CINECA project codes: check with Lucia Doni whether IsCd6_SPECC and IscrC_SPECC are the same or different projects
- [ ] fix various agents.md files...use only one and create links to it
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

#### Account Details and Access

The Leonardo cluster uses OIDC-based authentication through Step CA rather than traditional SSH keys. The account details are:
- **HPC Username**: `epezzano`
- **Login Host**: `login.leonardo.cineca.it`
- **Email**: `enricopezzano@disroot.org`
- **HPC Project**: `IsCd6_SPECC` (UserDB) / `IscrC_SPECC` (Leonardo workspace)
- **Workspace Path**: `/leonardo_work/IscrC_SPECC/`
- **Validity**: February 2026 to November 2026

The authentication flow works as follows: the SSH agent handles the credentials, Step CA manages the OIDC token through a browser-based login, and subsequent SSH/SCP commands use that token automatically. This approach eliminates the need to manage separate SSH keys for HPC access.

**Setup and Login**

Start the SSH agent first:
```bash
eval $(ssh-agent -s)
```

Then authenticate with your OIDC credentials (this opens a browser):
```bash
step ssh login 'enricopezzano@disroot.org' --provisioner cineca-hpc
```

After authentication, you can connect to Leonardo:
```bash
ssh REDACTED_USERNAME@login.leonardo.cineca.it
```

If backspace and arrow keys don't work in the terminal, set the TERM variable:
```bash
export TERM=xterm
```

The Leonardo frontend is a login node; from there you can submit SLURM jobs, check queue status, or transfer files. File transfers use SCP:
```bash
# Upload files from local machine to Leonardo home
scp -r /home/enriicola/Desktop/tesi REDACTED_USERNAME@login.leonardo.cineca.it:~/

# Download files from Leonardo
scp -r REDACTED_USERNAME@login.leonardo.cineca.it:~/results /local/destination/
```

**Automation Script**

For repeatability, the `cineca-setup.sh` script automates the agent and OIDC login:
```bash
#!/bin/bash
eval $(ssh-agent -s)
step ssh login 'enricopezzano@disroot.org' --provisioner cineca-hpc
```

Run this once per session, then use SSH and SCP without re-entering credentials. The script can also be extended to handle agent persistence across shell sessions by saving the agent PID and socket location to a file, though this is optional for one-off jobs.

#### Hardware and Software

Leonardo is an Atos Bull HPC system with two main compute modules:

**Booster Module** (3456 nodes):
- 32 Intel Ice Lake cores per node at 2.60 GHz
- 4 NVIDIA Ampere A100 GPUs (64 GB each) per node
- 512 GB RAM per node

**General Purpose Module** (1536 nodes):
- 2×56 Intel Sapphire Rapids cores per node at 2.00 GHz
- 512 GB RAM per node

The nodes are interconnected by a 200G HDR Infiniband Dragonfly+ network. Job scheduling uses SLURM 22.05. The system runs Red Hat Enterprise Linux 8.7 and supports Apptainer for container execution. Software environments can be managed via Spack modules.

#### Job Submission with SLURM

Jobs are submitted to the SLURM scheduler rather than run interactively. This allows long-running analyses to persist after disconnecting from the login node. A job script specifies resource requirements (CPU cores, memory, time, GPU if needed) and the commands to execute.

Example job script (`run.sh`):
```bash
#!/bin/bash
#SBATCH --job-name=biomod_ensemble
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=256GB

cd /leonardo_work/IscrC_SPECC/High-Performance-Ecoinformatics
Rscript main.r > main_output.log 2>&1
```

Submit and monitor:
```bash
sbatch run.sh              # Submit job, returns immediately
squeue -u epezzano         # Check job status
tail -f main_output.log    # Watch output live
scancel <jobid>            # Cancel job if needed
```

The job runs independently on allocated compute nodes. You can disconnect from Leonardo and check results later.

### 4. Implementation Notes & Methodological Adjustments

#### Data Path Standardization
The ensemble modelling pipeline (`main.r`) was calibrated to operate within a containerized HPC environment on Cineca Leonardo. Critical adjustments included:

- **Input data structure**: Species occurrence data loaded from `./data/input/data_62768_rows.csv` (62,768 presence records for target species in Alpine grasslands).
- **Environmental predictor rasters**: Organized into three principal component reduced datasets:
  - Climatic PCA layers: `./data/input/PCA/baseline` (present-day) and `./data/input/PCA/Futuro/` (SSP3-7.0, SSP5-8.5 projections)
  - Topographic Roughness Index (TRI): `./data/input/TRI/`
  - Soil PCA layers: `./data/input/PCA/Suolo/`
- **Output directory**: Standardized to `./data/output/` for all model evaluations, projections, and timing logs.

#### Computational Resource Optimization
HPC resource constraints on Cineca Leonardo necessitated the following algorithmic and computational adjustments:

- **Parallel processing**: Initial allocation of 32 CPU cores per task exceeded user-level QOS (Quality of Service) limits. Empirical testing established 8 CPU cores as the optimal threshold within institutional resource allocation policies (--cpus-per-task=8 in SLURM directives).
- **Algorithm selection**: Five ensemble algorithms retained for cross-validation: GLM (Generalized Linear Models), GBM (Gradient Boosting Machines), ANN (Artificial Neural Networks), FDA (Flexible Discriminant Analysis), MAXNET. Bigboss strategy employed for hyperparameter tuning.
- **Ensemble aggregation**: Dual ensemble methods applied—EMmean (unweighted average) and EMcv (cross-validation weighted)—with ROC ≥ 0.6 as selection threshold.
- **Performance profiling**: Removed external profiling overhead (profvis) to reduce runtime overhead in production runs; timing metrics (formating, modeling, projection phases) logged internally via base R timing functions.

#### Data Validation & Coordinate Indexing
Careful verification of input data structure was essential for successful biomod2 integration:

- **Occurrence data columns**: Verified CSV structure (ID, species_name, X, Y, pseudo-absence_data) with correct coordinate indexing `spocc1[,3:4]` to extract projected UTM coordinates (EPSG:32632).
- **Raster cell filtering**: BIOMOD_FormatingData naturally identified duplicate occurrences within single raster cells (~1 km² resolution) and issues a standard warning. No filtering applied (`filter.raster = FALSE`) to preserve occurrence density information.
- **Pseudo-absence strategy**: Random pseudo-absence selection (10,000 absences per 5-fold partition) applied within available raster extent to establish negative training samples.

#### Calibration & Projection Strategy
- **Calibration extent**: Europe-wide extent using full Alpine dataset (100,000 presence records per species subset after sampling; 5-fold random cross-validation with 70% training, 30% testing).
- **Projection extent**: Alps-specific region with current and future climate scenarios projected onto same environmental space.
- **Evaluation metrics**: TSS (True Skill Statistic), ROC (Receiver Operating Characteristic), KAPPA (Cohen's Kappa), POD (Probability of Detection), FAR (False Alarm Ratio) computed for individual models; ROC and TSS retained for ensemble model selection.

### 5. Planned Analyses & Future Work
- **Results Extraction**: Extraction and visualization of model evaluation metrics (TSS, ROC/AUC, etc.).
- **Hotspot Analysis**: Identification of climate refugia or areas of high vulnerability for the target species.
- **Full species loop**: Extend from current single-species calibration (i=3, hardcoded) to full 62,768-row dataset with species-level stratification.
- **Improvements**: Uncertainty quantification via ensemble variance; sensitivity analysis on pseudo-absence strategies.

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
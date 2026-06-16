# High Performance Ecoinformatics: MSc thesis 

## Setup for Collaborators

This repository uses Git LFS for large files (`.tif`, `.pdf`, `.csv`). After cloning:

```bash
git config core.hookspath .githooks
git lfs install
git lfs pull
```

---

## notes

project work dir -> /leonardo_work/IscrC_SPECC
PCA means climate variables (...)
Il mio account iscrc_specc può usare solo:
- dcgp_qos_bprod (minimo nodi, non va per 1 nodo)
- dcgp_qos_dbg (debug, tempo corto ma 1 nodo ok)
- dcgp_qos_lprod (low production)
- normal

ROC non va bene, bisogna usare AUCroc

### Come usare sbatch su Leonardo
-> nel repo root su Leonardo:
git pull                    # prendi script aggiornati
sbatch scripts/sbatch.sh    # invia job allo scheduler

#### Monitorare:
squeue --me                 # stato (PD=pending, R=running)
tail -f job.out             # log live (stdout)
tail -f job.err             # errori
scancel <jobid>             # annullare

### appunti cc

- `makeCluster`/`foreach` hangs inside Singularity → disabled; use biomod2 internal `nb.cpu` instead
- biomod2 API changes: `BIOMOD_ModelingOptions()` → `bm_ModelingOptions(strategy='bigboss')`, `ROC` → `AUCroc`
- stdout/stderr merged to single `.log` file for easier debugging; progress messages `[1/6]...[6/6]` added
- OOM in step 6 `BIOMOD_EnsembleForecasting`: biomod2 forks `mclapply` workers, each copy-on-write inherits big parent (rasters + models) → RAM × N workers → kernel kills workers → dead worker returns non-SpatRaster → `[names<-] incorrect number of names` → species FALLITA. NB: `tryCatch` hides it, job "completes" but ensemble + future outputs missing
- `nb.cpu` cap lowered (56 → 16) didn't fix step 6; forking is the issue, not core count
- step 6 internal: `BIOMOD_EnsembleForecasting` reloads all models (`load_stored_object`) and re-projects via `BIOMOD_Projection(..., nb.cpu = nb.cpu)` (its default is 1) — yet log still shows a ≥10-worker `mclapply` fork there; real fork source unresolved
- workaround for the 1-species test: `n_cpu <- 1L` (fully sequential) → no fork anywhere → no OOM → all outputs (ensemble + future) produced. Slower but guaranteed. Re-tune parallelism before the full multi-species run

#### run history (mini dataset, 1 species Achillea atrata)

- `52004b2` (nb.cpu=16) → **FAIL** OOM at step 6 forecasting (fork copies big parent)
- `354e415`/`52004b2` (nb.cpu≥16, time=12h) → **FAIL** also hit 12h timeout on some runs
- `bc71039` (n_cpu=1, time=12h) → **FAIL** time limit at FUTURE 2/8 (sequential too slow for 8 futures in 12h)
- `e622491` (n_cpu=1, time=72h, path `R/` fixed) → **SUCCESS** full run, `real 50.3h`, 0 OOM, 0 FALLITA, current + 8 futures complete
- note: `dcgp_qos_lprod` MaxWall = 4 days → 72h fits the 50h sequential run

#### "false positives" in the success log

- log runs with `options(echo=TRUE)` → R prints the script source before executing it. So `grep` over `job.log` matches words inside the *printed code*, not real events:
  - `FALLITA` (1 hit) = the error-handler definition line, never triggered
  - `oom` (4 hits) = the words `zoom` / `mask, zoom` (package masking msgs) + 2 of our own comments containing "OOM". No real `oom_kill`.

#### this run in detail

- 1 species, `small_1km_EUNIS.csv` (9 occurrences), reduced params: PA.nb.rep=2, PA.nb.absences=500, CV.nb.rep=2 → 35 model runs (incl. allRun/allData from `CV.do.full.models`)
- ensemble EMmean+EMcv, select AUCroc>0.6; projections: current + 8 futures (gfdl/ipsl/mpi/mri × ssp370/585)
- ⚠️ produces leftover junk in `data/output/` (stale species dirs, case-dup `proj_CurrentEM`, `proj_Tmp*`) — clean before delivery (see todo.md)
- ⚠️ mini output is NOT deliverable to collaborators (test params/data); needs full dataset + full params

---

## data folder instructions

the script needs to have 2 subfolder to work:

- input
- output

if not present, the script will create them and use them to run the various computations

## our tests

in our case, we chose to download some climate and soil data from <https://www.chelsa-climate.org>

- climate and soil variables are the old PCA folder

---

## Thesis Notes

- formerly `data_1km_eunis.txt` dataset contains presence/absence points of the target species, mapped at a 1 km² resolution.
- PCA: principal component analysis
- baseline: present-day climate and soil conditions
- Future Projections:
  - **SSP3-7.0**: Intermediate/high greenhouse gas emissions scenario.
  - **SSP5-8.5**: Pessimistic/worst-case greenhouse gas emissions scenario.

## draft table of contents (index)

1. Introduction
2. Methodology & Software Stack
3. High-Performance Computing (Cineca Leonardo)
   1. Access & Authentication
   2. Hardware & Software Environment & Booster module and Containerization
   3. Job Submission & Management with SLURM
4. Implementation Notes & Methodological Adjustments

## ssh cineca notes

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

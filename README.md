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
tail -f job.log             # log live (stdout+stderr merged)
scancel <jobid>             # annullare

### appunti cc

- `makeCluster`/`foreach` hangs inside Singularity → disabled; use biomod2 internal `nb.cpu` instead
- biomod2 API changes: `BIOMOD_ModelingOptions()` → `bm_ModelingOptions(strategy='bigboss')`, `ROC` → `AUCroc`
- stdout/stderr merged to single `.log` file for easier debugging; progress messages `[1/6]...[6/6]` added
- OOM in step 6 `BIOMOD_EnsembleForecasting`: biomod2 forks `mclapply` workers, each copy-on-write inherits big parent (rasters + models) → RAM × N workers → kernel kills workers → dead worker returns non-SpatRaster → `[names<-] incorrect number of names` → species FALLITA. NB: `tryCatch` hides it, job "completes" but ensemble + future outputs missing
- `nb.cpu` cap lowered (56 → 16) didn't fix step 6; forking is the issue, not core count
- step 6 internal: `BIOMOD_EnsembleForecasting` reloads all models (`load_stored_object`) and re-projects via `BIOMOD_Projection(..., nb.cpu = nb.cpu)` (its default is 1) — yet log still shows a ≥10-worker `mclapply` fork there; real fork source unresolved
- workaround for the 1-species test: `n_cpu <- 1L` (fully sequential) → no fork anywhere → no OOM → all outputs (ensemble + future) produced. Slower but guaranteed. Re-tune parallelism before the full multi-species run
- Lustre (filesystem HPC Leonardo) ottimizzato per file grandi, pessimo per tante operazioni metadata; ogni `stat()` = round-trip rete a MDT → `git status` con ~100 file = blocco
- `GIT_LFS_SKIP_SMUDGE=1` non aiuta: salta download ma git comunque stat() tutti i file
- ipotesi workaround: evitare git ops su `/leonardo_work/`, fare git da locale e rsync su Leo (non testato)
- anche tab completion (`tail -f j<TAB>`) si blocca su Lustre sotto carico
- `options(echo=TRUE)` + `options(warn=1)` → log live; senza echo stdout bufferizzato (job.log vuoto per ore)
- warning `glm.fit: fitted probabilities numerically 0 or 1` normale con pochi PA, non fatale

#### run history

- `52004b2` (nb.cpu=16) → **FAIL** OOM at step 6 forecasting (fork copies big parent)
- `354e415`/`52004b2` (nb.cpu≥16, time=12h) → **FAIL** also hit 12h timeout on some runs
- `bc71039` (n_cpu=1, time=12h) → **FAIL** time limit at FUTURE 2/8 (sequential too slow for 8 futures in 12h)
- `e622491` (n_cpu=1, time=72h, path `R/` fixed) → **SUCCESS** full run, `real 50.3h`, 0 OOM, 0 FALLITA, current + 8 futures complete
- note: `dcgp_qos_lprod` MaxWall = 4 days → 72h fits the 50h sequential run
- `b26fbd3` (1000 occ Agrostis, toy params PA.nb.rep=3 PA.nb.absences=10 CV.nb.rep=2) → **SUCCESS** `real 17.2h`, 30 models, 8 futures, 0 OOM
- `81e6fc4` (full 170701 Agrostis, `n_cpu=4` on modeling/projection, PA.nb.absences=10) → **SUCCESS** (job 47333938, node lrdn3952) `real 4h23m`, **0 OOM**, MaxRSS peak **326 GB** (fits 512GB node; `n_cpu=8` looks risky). `n_cpu=4` validated. Notes: extreme imbalance 170701:10 → `FDA failed! *** single value predicted` (toy PA); `NAs produced by integer overflow` in metric eval (forecast×observed counts exceed 32-bit int on the 64M-cell space). gawk `[HH:MM:SS]` stamps + pre-run `data/output` wipe confirmed on the compute node.

#### parallelism result (`n_cpu=4`, full 170701 Agrostis vs 1k@`n_cpu=1`)

- **Headline: full 170701 rows finished in 4h23m — *faster* than the 1k sequential run (17.2h).** The `n_cpu=4` lever cut the dominant projection phase ~4×, exactly as predicted. Row count barely matters; parallel projection is the whole game.
- per-phase timing (`time_<sp>.txt`, now in **seconds** — units fix verified, columns sum exactly to `real` 263m):

  | phase | secs | min | % wall |
  |---|---|---|---|
  | formating | 49.8 | 0.8 | 0.3% |
  | modeling | 784.3 | 13.1 | 5.0% |
  | modeling_EM | 42.1 | 0.7 | 0.3% |
  | cur_projection | 633.8 | 10.6 | 4.0% |
  | cur_projection_EM | 1024.9 | 17.1 | 6.5% |
  | **fut_projection** | **13254.2** | **220.9** | **84%** |

- `fut_projection` (8-scenario loop) still dominates at 84% → it's the only phase worth optimizing further. Was ~15h at `n_cpu=1`, now 3.7h.
- CPU eff: user/real = 407m/263m ≈ 1.5 cores avg — parallelism helps only the projection phases (rest stay serial), so the average stays well under 4.
- next lever: `n_cpu=8` could halve `fut_projection` again, but MaxRSS already 326 GB at 4 → 8 forks may exceed 512 GB. Test cautiously, or parallelize across scenarios instead of within projection.

#### benchmark findings (9-row Achillea vs 1k-row Agrostis)

| | 9-row | 1k-row |
|---|---|---|
| wall (real) | 7h01m (421m) | 17h14m (1033m) |
| user / sys CPU | 350m / 117m | 952m / 129m |
| CPU eff (user/real) | 0.83 (~1 core) | 0.92 (~1 core) |
| GBM | failed 6/6 (too few pts) | 0 fails, ran |
| surviving models | 24 (4 algos × 6) | 30 (5 algos × 6) |
| FormatingData | ~48s | ~49s |

- **Finding 1 — single-core waste.** `sbatch.sh` requests `--cpus-per-task=56 --mem=0 --time=72h`, but the R script forces `nb.cpu=1` at all 5 call sites → **~1.8% node utilization, 55 cores idle for 17h**. This is the cost of the step-6 fork/OOM workaround (forking `mclapply` → OOM → forced sequential). The 17h is the price of that workaround, not an algorithmic floor.
- **Finding 2 — 17h is NOT a real-run estimate.** `PA.nb.absences=10` is a toy value; a real run needs ~10000 PAs → training set explodes → modeling time grows hard. Projection time (the dominant chunk) stays flat. So the 17h is a lower bound dominated by projection, not a forecast of the full run.
- **Scaling implication.** Cost ≈ `fixed_IO(~2h, set by raster size) + Σ_models(fit) + N_models × N_scenarios × cells × proj_cost`. Occurrence count only feeds `fit`: 111× more data (9→1000) bought only 2.5× wall. Wall is driven by **PA count + model count + #scenarios × raster cells**, barely by occurrence count. The only real lever for the full multi-species run is parallelism across the 9 projection scenarios / models — which reopens the step-6 fork/OOM problem `n_cpu=1` was set to dodge.
- per-phase timing is written to `data/output/time_<species>.txt`, but ⚠️ `write.table` on `difftime` **strips the units** and R auto-picks a unit per value, so columns aren't comparable (e.g. `formating`=secs, `fut_projection`=hours). Dominant phase is `fut_projection` (the 8-scenario loop) in both runs. Fix: store `as.numeric(diff, units="secs")`.

#### speedup attempt + tooling changes (full 170701-row Agrostis)

- **sbatch config is NOT the lever.** Job already requests 56 cores + `mem=0` (full ~512GB DCGP node); R uses `nb.cpu=1` → 1 core. Tuning SLURM does nothing. Speed is gated by the `nb.cpu=1` workaround in the R code.
- **lever = R `nb.cpu`.** `test_risolto.R`: added `n_cpu <- 4L`, wired into `BIOMOD_Modeling` + both `BIOMOD_Projection` (current/future). `EnsembleModeling` + both `EnsembleForecasting` stay `nb.cpu=1` (their `bm.proj` reuse already avoids the step-6 re-projection fork — the original OOM source). Projection parallelizes across the 30 models → `fut_projection` ~15h could drop to ~2–4h.
- ⚠️ **OOM risk**: this is the fork the `nb.cpu=1` workaround dodged. History: `nb.cpu=16/56` → OOM. `n_cpu=4` is the cautious first test; on OOM (FALLITA / log dies mid-projection, check `oom_kill`) drop to 2/1, on clean run try 8.
- **why the row count is not scary**: projection cost = raster cells × models × scenarios, **independent of occurrence count**. 170701 vs 1000 rows only grows the modeling (fit) phase. Est. wall at `n_cpu=4` ≈ 8–14h (fits 72h).
- removed the line-77 `spocc1[1:min(1000,...)]` truncation → full 170701 rows. `PA.nb.absences=10` still toy → this is a timing/parallelism test, not deliverable science.
- `sbatch.sh`: wipes `data/output` before each run (`find ... ! -name expected_output_foreach_species.txt -delete`) to avoid leftover-junk accumulation; pipes Rscript stdout/stderr through `gawk strftime` → every log line gets a live `[HH:MM:SS]` stamp (host-side, needs gawk not mawk on the compute node).

#### "false positives" in the success log

- log runs with `options(echo=TRUE)` → R prints the script source before executing it. So `grep` over `job.log` matches words inside the *printed code*, not real events:
  - `FALLITA` (1 hit) = the error-handler definition line, never triggered
  - `oom` (4 hits) = the words `zoom` / `mask, zoom` (package masking msgs) + 2 of our own comments containing "OOM". No real `oom_kill`.

#### this run in detail

- 1 species, `small_1km_EUNIS.csv` (9 occurrences), reduced params: PA.nb.rep=2, PA.nb.absences=500, CV.nb.rep=2 → 35 model runs (incl. allRun/allData from `CV.do.full.models`)
- ensemble EMmean+EMcv, select AUCroc>0.6; projections: current + 8 futures (gfdl/ipsl/mpi/mri × ssp370/585)
- ⚠️ produces leftover junk in `data/output/` (stale species dirs, case-dup `proj_CurrentEM`, `proj_Tmp*`) — clean before delivery (see todo.md)
- ⚠️ mini output is NOT deliverable to collaborators (test params/data); needs full dataset + full params

#### versione aggiornata (`R/test_risolto.R`)

Differenze chiave vs `new.ensamble_modelling.R`:

- **`BIOMOD_EnsembleForecasting(bm.proj = ...)` invece di `new.env = ...`**: riusa la proiezione single-models già calcolata → niente ri-proiezione interna → niente fork `mclapply` → **niente OOM allo step 6**. È il meccanismo che ci mancava.
- biomod2 richiede **XOR(bm.proj, new.env)**: passarli entrambi → `stop("bm.proj or new.env is missing")` (sorgente `BIOMOD_EnsembleForecasting.R:587`). Lo script di Lucia li passava entrambi (WIP) → corretto: solo `bm.proj`.
- `CV.do.full.models = FALSE` → niente modelli allRun/allData.
- `selModels` usa **MAXNET** (non MARS).
- adattamenti per girare nel container: path `./data/input/...`, niente `makeCluster`, niente `dplyr`, fix `OPT.strategy = 'bigboss',,`.

Note dal primo run (params toy: 9 occ + 10 PA):
- **GBM fallisce** (`data set too small ... nTrain*bag.fraction <= 2*n.minobsinnode+1`): troppi pochi punti. Non fatale, biomod salta GBM. Sparisce con dati/params reali.

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

- dataset `full_1km_EUNIS.csv`: 2,583,359 presence rows, 167 species, 1 km² resolution. Most abundant single species = `Agrostis capillaris` (170,701 rows) → worst-case for per-species benchmarking. Subset `agrostis_1km_EUNIS.csv` extracted for that benchmark.
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

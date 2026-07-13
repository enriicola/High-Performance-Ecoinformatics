# Session Notes - 2026-07-03

## Status
- 3 test jobs (48325677_3, 48325677_4, 48325677_5) running on Leonardo DCGP nodes
- Jobs appear stuck on BIOMOD_FormatingData → pseudo-absence selection
- Actually processing (99% CPU, ~100 min CPU time each)

## Investigation Results

### Bottleneck Found
`BIOMOD_FormatingData` with `PA.strategy="random"` on large SpatRaster is **very slow**.

Root cause: biomod2's `bm_PseudoAbsences_random` for SpatRaster branch:
- 64M cell raster + 170k occurrence points + 10 PA replicas × 10k absences each
- Each rep: ~60s (observed 1 rep 100 PA = 60s)
- 10 reps × 10k PA = multiple hours (not bug, just slow algorithm)

Profiling breakdown:
- `.get_data_mask()`: 13-15s
- `cellFromXY` + mask update: 1-2s
- `spatSample` per rep: 7s
- `values()` scans on 64M cells: **5+ minutes** (bottleneck)
- Loop repeats 10× → hours

### Fix Applied
Changed `scripts/sbatch.sh`:
- `--cpus-per-task=56` → `--cpus-per-task=112`
- Confirmed via `sinfo`: DCGP nodes = 112 CPU each
- Pushed to GitHub, pulled on Leonardo

### Why Not Optimized Yet
PA params (10 reps, 10k absences) are correct per biologists' request. Full dataset run needs this.

## Job 3 Crash (CRITICAL)

Job 3 **FAILED** at 507m (8.5h):
- "Execution halted" during `BIOMOD_EnsembleForecasting` parallel projections
- Error: `[writeRaster] file exists. You can use 'overwrite=TRUE' to overwrite it`
- Root cause: Parallel tasks (nb.cpu > 1) writing individual projection files collide
- Multiple `%dopar%` tasks tried writing same `proj_current_*.tif` simultaneously

Impact: Jobs 4,5 will hit same crash. Full 167-job run will fail.

## Next Steps
- Run reproducible jobs with `seed_val <- 42L` and `overwrite=FALSE` in `BIOMOD_Projection`
- Study if `seed.val=42` makes pseudo-absence + model outputs stable enough for safe resume
- Study `overwrite=FALSE` vs `TRUE`: FALSE saves time by reusing existing projections; TRUE safer after code/input/model changes
- 2026-07-05: `--mem=100G` too low even for first SJF species; all 5 jobs OOM during current `BIOMOD_EnsembleForecasting`
- Prepare full array job (1-167 species) after test

## Split vs monolithic benchmark

Same Leonardo test: `small_1km_EUNIS.csv`, 1 PA replica, 10 pseudo-absences, 1 CV repeat, no future projections.

| Version | Wall time | MaxRSS |
|---|---:|---:|
| Split #1 | 26m18s | 48.3 GiB |
| Split #2 | 25m53s | 47.1 GiB |
| Split #3 | 25m51s | 48.0 GiB |
| Split #4 | 26m00s | 40.3 GiB |
| Monolithic #1 | 26m14s | 42.9 GiB |
| Monolithic #2 | 26m28s | 45.4 GiB |
| Monolithic #3 | 26m05s | 45.4 GiB |
| Monolithic #4 | 26m26s | 44.2 GiB |

Across four runs, split averaged **26m01s / 45.9 GiB** and monolithic averaged **26m18s / 44.5 GiB**. Runtime is effectively equivalent; split was 18 seconds faster on average (~1.1%). The 1.4 GiB average RSS difference is not a stable separation overhead: Split #4 used 3.9 GiB less RAM than its paired monolithic run, and split RSS ranged from 40.3 to 48.3 GiB. `ctx` is an R environment passed by reference, not a copy of the workflow data.

### Controlled benchmark

One exclusive Leonardo node (`lrdn3758`), fixed seed (`42`), `R_DEBUG_ECHO=false`, `OMP_NUM_THREADS=1`, and alternating serial runs. MaxRSS was measured by `/usr/bin/time -v`.

| Run | Version | Duration | MaxRSS |
|---:|---|---:|---:|
| 1 | Split | 26m10s | 47.04 GiB |
| 2 | Monolithic | 26m06s | 47.36 GiB |
| 3 | Monolithic | 26m18s | 47.36 GiB |
| 4 | Split | 25m59s | 47.04 GiB |
| 5 | Split | 26m05s | 47.04 GiB |
| 6 | Monolithic | 26m27s | 47.09 GiB |
| 7 | Monolithic | 26m15s | 48.16 GiB |
| 8 | Split | 26m26s | 47.04 GiB |
| 9 | Split | 26m08s | 47.28 GiB |
| 10 | Monolithic | 27m12s | 48.16 GiB |

| Average | Duration | MaxRSS |
|---|---:|---:|
| Split | **26m10s** | **47.09 GiB** |
| Monolithic | **26m28s** | **47.63 GiB** |
| Split − monolithic | **−18s** | **−0.54 GiB** |

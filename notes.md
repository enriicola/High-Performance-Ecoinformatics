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
- Prepare full array job (1-167 species) after test

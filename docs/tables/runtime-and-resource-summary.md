# Runtime and resource summary

## Scope

This document consolidates the runtime and resource data currently recorded in `logs/` and `docs/work-in-progress/appunti.md`. It contains measured observations only. `NA` means that the available sources do not record the value. [`local-log-metadata.md`](local-log-metadata.md) provides a linked index of the fields written directly in each local R job log.

The runs are not all directly comparable. They use different species, input sizes, pseudo-absence settings, cross-validation repetitions, model counts, worker counts, storage modes and script revisions. Only the experiments explicitly described as controlled should be used to calculate speedups.

Array tasks are identified as `<array job ID>_<task ID>`. The `Job:` field inside a log may contain the Slurm job ID assigned to the individual task, which can differ from the array job ID used in the filename.

### Storage notation

| Code | `keep.in.memory` | `do.stack` |
|---|---|---|
| T/T | `TRUE` | `TRUE` |
| F/T | `FALSE` | `TRUE` |
| T/F | `TRUE` | `FALSE` |
| F/F | `FALSE` | `FALSE` |

`default T/T` means that both arguments were omitted and BIOMOD2 used its defaults.

### Memory measurements

Two memory measurements appear in the sources:

- **Slurm MaxRSS** covers the batch allocation and is the value used to assess node memory pressure.
- **Process MaxRSS** comes from GNU `time -v`. It may exclude memory used by forked workers, especially when a child is killed. It must not replace Slurm MaxRSS in OOM analysis.

## Workload

| Variable | Recorded value | Source |
|---|---:|---|
| Species | 167 | `docs/work-in-progress/appunti.md`, "Contesto scientifico e obiettivo del lavoro" |
| Occurrence records | 2,583,359 | Same section |
| Occurrence range per species | 43 to 170,701 | Same section |
| *Achillea atrata* occurrences | 1,475 | Same section and run logs |
| Environmental raster cells | 63,951,097 | Same section |
| Environmental variables | 5 | Same section |
| Algorithms | 5: GLM, GBM, ANN, FDA, MAXNET | Same section |
| Ensembles | 2: EMmean, EMcv | Same section |
| Future scenarios | 8: 4 GCMs by 2 SSPs | Same section |
| Experimental model configuration | 5 PA repetitions by 5 CV repetitions by 5 algorithms, up to 125 individual models | `docs/work-in-progress/appunti.md`, "Fase 1" |
| Production model configuration | 10 PA repetitions by 5 CV repetitions by 5 algorithms, up to 250 individual models | Same section |

## Main Leonardo experiments

These runs provide the clearest full-raster evidence. Unless noted otherwise, they used *Achillea atrata*, 1,475 occurrences, five pseudo-absence repetitions, five cross-validation repetitions, five algorithms and two ensemble models. Ensemble phases used at most two workers.

| Run | Start date | Node | BIOMOD workers | Storage | Status | Elapsed | Slurm MaxRSS (GiB) | Output validation | Primary sources |
|---|---|---|---:|---|---|---:|---:|---|---|
| `49842976_1` | 2026-07-19 | `lrdn4717` | 2 | F/T | Failed: `mcfork()` could not allocate memory during the first future scenario | 05:43:54 | 413.22 | No `_SUCCESS` or final timings | `logs/job_49842976_1.log`, `logs/resources_49842976_1.txt` |
| `49843592_1` | 2026-07-19 | `lrdn4682` | 4 | F/T | Failed: same fork failure and phase | 03:57:22 | 413.80 | No `_SUCCESS` or final timings | `logs/job_49843592_1.log`, `logs/resources_49843592_1.txt` |
| `49844162_1` | 2026-07-19 | `lrdn4376` | 4 | F/F | Completed | 22:33:45 | 260.94 | 1,364 non-empty files, about 7.2 GB, 127 model files, eight future scenarios and `_SUCCESS` | `logs/job_49844162_1.log`, `logs/resources_49844162_1.txt` |
| `51485472_1` | 2026-08-01 | `lrdn4939` | 4 | T/F | Completed | 22:21:32 | 264.69 | 1,368 non-empty files, about 7.3 to 7.4 GB, timing files and `_SUCCESS` | `logs/job_51485472_1.log`, `logs/resources_51485472_1.txt` |
| `51494635_1` | 2026-08-01 | `lrdn4454` | 6 | F/F | Completed | 17:50:53 | 258.95 | Same validation as `51485472_1` | `logs/job_51494635_1.log`, `logs/resources_51494635_1.txt` |
| `51485581_1` | 2026-08-01 | `lrdn4946` | 8 | F/F | Completed | 15:05:30 | 278.67 | Same validation as `51485472_1` | `logs/job_51485581_1.log`, `logs/resources_51485581_1.txt` |
| `51738981_1` | 2026-08-02 | `lrdn4795` | 16 | F/F | Completed according to wrapper and notification | 10:21:23 | NA; 464.77 recorded during scenario 3 | Final accounting and output details not validated | `logs/job_51738981_1.log`, `logs/resources_51738981_1.txt` |
| `51739004_1` | 2026-08-02 | `lrdn3936` | 16 | T/F | OOM during the first future scenario | 02:57:12 | 472.57 | Incomplete | `logs/job_51739004_1.log`, `logs/resources_51739004_1.txt` |
| `51739048_1` | 2026-08-02 | `lrdn3756` | 32 | F/F | OOM during current projection; 12 workers did not return | 01:39:54 | 481.16 | Incomplete | `logs/job_51739048_1.log`, `logs/resources_51739048_1.txt` |
| `51756264_1` | 2026-08-02 | `lrdn4863` | 12 | F/F | Time limit | 09:30:20 in Slurm notes; wrapper timestamps span 09:40:11 | NA | Incomplete | `logs/job_51756264_1.log`, `docs/work-in-progress/appunti.md` |
| `51756286_1` | 2026-08-02 | `lrdn4866` | 12 | T/F | Time limit | 09:30:18 in Slurm notes; wrapper timestamps span 09:40:13 | NA | Incomplete | `logs/job_51756286_1.log`, `docs/work-in-progress/appunti.md` |
| `55020903_1` | 2026-08-29 | `lrdn4946` | 8 | F/F | Completed, production configuration | 25:36:36 in wrapper; 25:36:42 in Slurm accounting | about 316 | 2,614 files and `_SUCCESS` | `logs/job_55020903_1.log`, `logs/resources_55020903_1.txt`, `docs/work-in-progress/appunti.md` |
| `55020903_2` | 2026-08-30 | `lrdn3956` | 8 | F/F | Completed, production configuration | NA | about 316 | 2,614 files and `_SUCCESS` | `logs/job_55020903_2.log`, `docs/work-in-progress/appunti.md` |
| `55020903_3` | NA | NA | 8 | F/F | Completed, production configuration | 33:58:37 | about 291 | 2,614 files and `_SUCCESS` | `docs/work-in-progress/appunti.md` |

The production runs used ten pseudo-absence repetitions and five cross-validation repetitions. They are not controlled comparisons with the earlier five-repetition runs.

## Full-raster phase timings

All values are seconds. `Future loop` includes all eight future scenarios. The sources do not preserve the individual and ensemble modeling times for the three August runs, so those cells are `NA`.

| Run | Workers | Storage | Formatting | Individual modeling | Ensemble modeling | Current projection | Current ensemble | Future loop | Future share of wall time |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|
| `49844162_1` | 4 | F/F | 4,527.93 | 248.85 | 137.30 | 7,047.56 | 1,421.92 | 67,818.98 | 83.5% |
| `51485472_1` | 4 | T/F | 4,490.02 | NA | NA | 6,988.68 | 1,467.62 | 67,139.91 | 83.4% |
| `51494635_1` | 6 | F/F | 4,600.66 | NA | NA | 5,132.52 | 1,451.78 | 52,735.75 | 82.1% |
| `51485581_1` | 8 | F/F | 4,531.17 | NA | NA | 4,057.93 | 1,448.78 | 43,996.87 | 81.0% |

Source: `docs/work-in-progress/appunti.md`, "Fase 6" and "Fase 7".

## Worker-count comparison

The 4-, 6- and 8-worker F/F runs used the same species and scientific configuration. Each configuration was run once, so run-to-run variability is unknown.

| Workers | Run | Wall time (h) | Speedup over 4 workers | Wall-time reduction | Slurm MaxRSS (GiB) |
|---:|---|---:|---:|---:|---:|
| 4 | `49844162_1` | 22.56 | 1.000 | 0.0% | 260.94 |
| 6 | `51494635_1` | 17.85 | 1.264 | 20.9% | 258.95 |
| 8 | `51485581_1` | 15.09 | 1.495 | 33.1% | 278.67 |

The additional change from six to eight workers gave a speedup of 1.183 and reduced wall time by 15.4%.

The 4-worker T/F run `51485472_1` took 22.36 hours. Compared with the 4-worker F/F reference, it was 0.9% faster and used 3.75 GiB more Slurm MaxRSS. A single run per storage mode is not enough to establish a stable storage effect.

### CPU utilization for the August runs

| Workers | Run | Storage | Slurm CPU-hours | Allocated CPU-hours | Average active cores | Allocation utilization |
|---:|---|---|---:|---:|---:|---:|
| 4 | `51485472_1` | T/F | 70.68 | 89.44 | 3.16 | 79.0% |
| 6 | `51494635_1` | F/F | 72.95 | 107.09 | 4.09 | 68.1% |
| 8 | `51485581_1` | F/F | 72.51 | 120.74 | 4.80 | 60.0% |

Increasing the worker count reduced wall time, but the fraction of allocated CPU time used by the workload fell.

Source: `docs/work-in-progress/appunti.md`, "Fase 7".

## Controlled split versus monolithic benchmark

Conditions: one exclusive Leonardo node (`lrdn3758`), fixed seed 42, `OMP_NUM_THREADS=1`, one pseudo-absence repetition, ten pseudo-absences, one cross-validation repetition, no future projections and serial alternating runs.

### Run-level results

| Run | Version | Elapsed | GNU `time` MaxRSS (GiB) | Exit code |
|---:|---|---:|---:|---:|
| 1 | Split | 26:10 | 47.04 | 0 |
| 2 | Monolithic | 26:06 | 47.36 | 0 |
| 3 | Monolithic | 26:18 | 47.36 | 0 |
| 4 | Split | 25:59 | 47.04 | 0 |
| 5 | Split | 26:05 | 47.04 | 0 |
| 6 | Monolithic | 26:27 | 47.09 | 0 |
| 7 | Monolithic | 26:15 | 48.16 | 0 |
| 8 | Split | 26:26 | 47.04 | 0 |
| 9 | Split | 26:08 | 47.28 | 0 |
| 10 | Monolithic | 27:12 | 48.16 | 0 |
| **Mean** | **Split** | **26:10** | **47.09** | **0** |
| **Mean** | **Monolithic** | **26:28** | **47.63** | **0** |
| **Split minus monolithic** |  | **-00:18** | **-0.54** |  |

Source: `logs/controlled_r_benchmark_launcher.log`, `logs/benchmark_split_vs_monolith_49303754/summary.tsv` and its `*_rss.tsv` files.

### Phase timings

All values are seconds. The future value is effectively zero because this benchmark disabled future projections.

| Run | Version | Formatting | Individual modeling | Ensemble modeling | Current projection | Current ensemble | Future projection |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | Split | 32.97 | 2.50 | 5.77 | 261.90 | 1,256.25 | 0.00 |
| 2 | Monolithic | 32.25 | 2.86 | 5.43 | 258.79 | 1,261.15 | 0.00 |
| 3 | Monolithic | 32.88 | 2.92 | 5.45 | 262.03 | 1,268.10 | 0.00 |
| 4 | Split | 32.59 | 2.55 | 5.80 | 261.26 | 1,250.88 | 0.00 |
| 5 | Split | 32.26 | 2.55 | 5.92 | 261.72 | 1,255.32 | 0.00 |
| 6 | Monolithic | 32.64 | 2.87 | 5.47 | 262.78 | 1,277.21 | 0.00 |
| 7 | Monolithic | 32.77 | 2.87 | 5.47 | 261.68 | 1,266.06 | 0.00 |
| 8 | Split | 32.53 | 2.51 | 5.76 | 267.00 | 1,271.60 | 0.00 |
| 9 | Split | 32.09 | 2.51 | 5.74 | 262.36 | 1,260.26 | 0.00 |
| 10 | Monolithic | 32.46 | 2.87 | 5.46 | 260.76 | 1,278.43 | 0.00 |

Source: `logs/benchmark_split_vs_monolith_49303754/*_phases.tsv`.

### Preliminary split versus monolithic series

The earlier eight-run series was not captured in its `summary.tsv`, which contains only a header. The values below come from the project notes.

| Version | Runs | Elapsed range | Mean elapsed | MaxRSS range (GiB) | Mean MaxRSS (GiB) |
|---|---:|---:|---:|---:|---:|
| Split | 4 | 25:51 to 26:18 | 26:01 | 40.3 to 48.3 | 45.9 |
| Monolithic | 4 | 26:05 to 26:28 | 26:18 | 42.9 to 45.4 | 44.5 |

Source: `docs/work-in-progress/appunti.md`, "Fase 5", and `logs/srun_{split,monolithic}_small_pa10*.log`.

## GNU `time -v` resource records

The filesystem input and output fields are GNU `time` counters, not byte counts. Process MaxRSS can be lower than Slurm MaxRSS because forked workers are not always represented in the parent-process peak.

| Resource record | User CPU (s) | System CPU (s) | Average CPU | Elapsed | Process MaxRSS (GiB) | FS inputs | FS outputs | Process exit |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `49629886_0` | 30,281.96 | 2,037.66 | 165% | 05:25:09 | 481.47 | 815,095 | 4,140,408 | 0 |
| `49630695_2` | 15,965.18 | 4,366.14 | 354% | 01:35:31 | 79.12 | 7,537,297 | 4,779,128 | 1 |
| `49842976_1` | 31,960.83 | 2,477.83 | 166% | 05:43:53 | 385.77 | 925,465 | 3,001,448 | 1 |
| `49843592_1` | 32,167.70 | 2,380.63 | 242% | 03:57:21 | 385.67 | 2,010,707 | 2,946,888 | 1 |
| `49844162_1` | 241,951.02 | 14,199.23 | 315% | 22:33:45 | 145.19 | 10,677,245 | 15,108,632 | 0 |
| `51485472_1` | 239,185.37 | 15,276.65 | 316% | 22:21:31 | 144.95 | 9,310,912 | 15,358,112 | 0 |
| `51485581_1` | 241,217.54 | 19,803.45 | 480% | 15:05:30 | 103.42 | 2,850,941 | 16,507,576 | 0 |
| `51494635_1` | 243,967.48 | 18,644.78 | 408% | 17:50:52 | 144.90 | 4,037,177 | 16,075,160 | 0 |
| `51738981_1` | 244,845.21 | 24,241.89 | 721% | 10:21:22 | 145.19 | 7,397,238 | 18,758,536 | 0 |
| `51739004_1` | 56,233.13 | 5,117.38 | 577% | 02:57:11 | 145.16 | 3,492,219 | 4,167,112 | 1 |
| `51739048_1` | 21,519.74 | 2,844.30 | 406% | 01:39:53 | 50.82 | 2,538,212 | 1,735,776 | 1 |
| `55020903_1` | 473,071.25 | 33,268.49 | 549% | 25:36:36 | 161.99 | 25,785,200 | 30,829,400 | 0 |

Source: non-empty `logs/resources_*.txt` files. Empty resource files provide no measurements and are represented by `NA` in the run inventory rather than this table.

## Historical and diagnostic run inventory

This table covers runs and campaigns not fully described in the main experiment table. Times are wall times when the source identifies them as such.

| Run or series | Species or scope | Occurrences | Workers | Storage | Status | Elapsed | Last recorded phase or reason | Sources |
|---|---|---:|---:|---|---|---:|---|---|
| `52004b2`, `354e415` | Legacy tests | NA | at least 16 | NA | Failed or timed out | up to 12 h | OOM during ensemble forecasting | `docs/work-in-progress/appunti.md`, "Fase 1" |
| `bc71039` | One legacy species | NA | 1 | NA | Time limit | 12 h | Future scenario 2 of 8 | Same source |
| Unidentified 9-row run | *A. atrata* toy input | 9 | 1 | NA | Completed | 00:07:01 | 24 surviving models | `logs/job9rows_ok.log`, project notes |
| `e622491` | Small test input | NA | 1 | default T/T | Completed | 50.3 h | Current and eight future scenarios | Project notes |
| `b26fbd3` | Agrostis toy input | 1,000 | 1 | default T/T | Completed | 17.2 h | About 30 models and eight future scenarios | `logs/job1krows_ok.log`, project notes |
| `47333938` | *A. capillaris* | 170,701 | 4 | default T/T | Completed | 04:23 | 10 pseudo-absences, 24 surviving models | `logs/job_agrostis_pa10_ok.log`, project notes |
| `47467973` | *A. capillaris* | 170,701 | 4 | default T/T | Completed | 11:50 | 10,000 pseudo-absences, 30 valid models | `logs/job_agrostis_pa10000_ok.log`, project notes |
| `47510573_1` | *P. erecta* | 167,345 | 4 | default T/T | Completed | 11:33 | Timing file present; peak about 360 GB | `logs/job_47510573_1.log`, project notes |
| `47510573_2` | *G. anisophyllon* | 5,936 | 4 | default T/T | Cancelled; OOM also recorded | about 18 h | Repeated SIGPIPE failures | `logs/job_47510573_2.log` |
| `47510573_3` | *F. glauca* | 332 | 4 | default T/T | Cancelled; OOM also recorded | about 18 h | Repeated SIGPIPE failures | `logs/job_47510573_3.log` |
| `47574797_2` | *G. anisophyllon* | 5,936 | 1 | default T/T | Failed | 03:12 | `writeRaster` path did not exist | `logs/job_47574797_2.log` |
| `47574797_3` | *F. glauca* | 332 | 1 | default T/T | Completed | 22:59:26 | Full sequential rerun | `logs/job_47574797_3.log`, Slurm accounting in project notes |
| `47593184_2` | *G. anisophyllon* | 5,936 | 1 | NA | Cancelled | NA | Detail lost; array had mixed state and maximum signal 9 | `logs/job_47593184_2.log`, project notes |
| `48075655_1` | *A. atrata* | 1,475 | 1 | default T/T | OOM | within 13 to 17 h | Future projection | `logs/job_48075655_1.log` |
| `48075655_2` | *A. clusiana* | 174 | 1 | default T/T | OOM | within 13 to 17 h | Future projection | `logs/job_48075655_2.log` |
| `48075655_3` | *A. capillaris* | 170,701 | 4 | default T/T | OOM | within 13 to 17 h | Future projection | `logs/job_48075655_3.log` |
| `48075655_4` | *A. rupestris* | 4,464 | 1 | default T/T | OOM | within 13 to 17 h | Future projection | `logs/job_48075655_4.log` |
| `48075655_5` | *A. fissa* | 1,428 | 1 | default T/T | OOM | within 13 to 17 h | Future projection | `logs/job_48075655_5.log` |
| `48075655_6` | *A. pentaphyllea* | 1,190 | 1 | default T/T | Cancelled | NA | Remaining campaign tasks stopped after the first five OOM events | `logs/job_48075655_6.log`, project notes |
| `48075655_7` | *Allium senescens* | 260 | 1 | default T/T | Cancelled | NA | Same campaign decision | `logs/job_48075655_7.log`, project notes |
| `48075655_8` | *Alyssum alyssoides* | 12,396 | 1 | default T/T | Cancelled | NA | Same campaign decision | `logs/job_48075655_8.log`, project notes |
| `48075655_[9-167]` | Remaining species | NA | NA | default T/T | Cancelled before execution | NA | Campaign stopped after repeated OOM events | Project notes |
| `48236130_1` | *A. atrata* | 1,475 | 1 | F/F | Interrupted deliberately | NA | Stopped before projection to change test species | `logs/job_48236130_1.log`, project notes |
| `48238919_3` | *A. capillaris* | 170,701 | 4 | F/F | Interrupted deliberately | about 22 h; accounting 22:40:40 | Reached future scenario 2 of 8 without OOM | `logs/job_48238919_3.log`, project notes |
| `48325677_3` | *A. capillaris* | 170,701 | 4 | F/F | Failed | about 08:27 | Parallel file collision in `writeRaster` | `logs/job_48325677_3.log`, project notes |
| `48325677_4` | *A. rupestris* | 4,464 | 1 | F/F | Cancelled | 42:47:42 | Last observed in pseudo-absence selection | `logs/job_48325677_4.log`, Slurm accounting in project notes |
| `48325677_5` | *A. fissa* | 1,428 | 1 | F/F | Cancelled | 42:47:42 | Last observed in pseudo-absence selection | `logs/job_48325677_5.log`, Slurm accounting in project notes |
| `48418427_3` | *A. capillaris* | 170,701 | 4 | F/F | Failed | 08:36:58 | Existing output file collision | `logs/job_48418427_3.log` |
| `48418427_4` | *A. rupestris* | 4,464 | 1 | F/F | Failed | 04:29:28 | Existing output file collision | `logs/job_48418427_4.log` |
| `48418427_5` | *A. fissa* | 1,428 | 1 | F/F | Failed | 04:05:04 | Existing output file collision | `logs/job_48418427_5.log` |
| `48606158_[1-3]` | Three shortest species | 43, 88, 174 | 1 | F/F | Cancelled | NA | Cancellation reason not recorded | `logs/job_48606158_*.log` |
| `48607206_[1-3]` | Three shortest species | 43, 88, 174 | 1 | F/F | Cancelled | NA | Cancellation reason not recorded | `logs/job_48607206_*.log` |
| `48607860_1` | *Festuca varia* | 43 | 1 | F/F | OOM | 17:14:15 | Process killed | `logs/job_48607860_1.log` |
| `48607860_2` | *Festuca versicolor* | 88 | 1 | F/F | OOM | 16:31:03 | Process killed | `logs/job_48607860_2.log` |
| `48607860_3` | *A. clusiana* | 174 | 1 | F/F | OOM | 14:33:40 | Process killed | `logs/job_48607860_3.log` |
| `48607860_4` | *Seseli osseum* | 206 | 1 | F/F | OOM | 18:52:22 | Process killed | `logs/job_48607860_4.log` |
| `48607860_5` | *Allium senescens* | 260 | 1 | F/F | OOM | 21:32:42 | Process killed | `logs/job_48607860_5.log` |
| `48873007_1` | *Festuca varia* | 43 | 1 | F/F | Failed | 13:24:22 | Could not write current-projection file | `logs/job_48873007_1.log` |
| `48873007_2` | *Festuca versicolor* | 88 | 1 | F/F | Time limit | NA | Future projection in progress | `logs/job_48873007_2.log` |
| `48873007_3` | *A. clusiana* | 174 | 1 | F/F | Failed | 15:16:13 | Empty raster filename at future scenario 1 | `logs/job_48873007_3.log` |
| `48873007_4` | *Seseli osseum* | 206 | 1 | F/F | Time limit | NA | Future projection in progress | `logs/job_48873007_4.log` |
| `48873007_5` | *Allium senescens* | 260 | 1 | F/F | Time limit | NA | Future projection in progress | `logs/job_48873007_5.log` |
| `49507005_1` | *A. atrata* | 1,475 | 5 | F/F | Cancelled | 38:12:21 | First wave of cancelled 167-species campaign | `logs/job_49507005_1.log`, Slurm accounting in project notes |
| `49507005_2` | *A. clusiana* | 174 | 5 | F/F | Cancelled | 38:12:37 | Same wave | `logs/job_49507005_2.log`, Slurm accounting in project notes |
| `49507005_3` | *A. capillaris* | 170,701 | 5 | F/F | Cancelled | 38:12:41 | Same wave | `logs/job_49507005_3.log`, Slurm accounting in project notes |
| `49507006-49507067` | Remaining 55 dependent waves | Species 4 to 167 | NA | F/F | Cancelled or never started | NA | Dependencies followed the unsuccessful first wave | `logs/campaign_20260716_022909.tsv`, project notes |
| `49628609_1` | *A. atrata* | 1,475 | 2 | NA | Cancelled | about 00:14 | Test stopped before a recorded result | `logs/job_49628609_1.log` |
| `49629886` | *A. atrata* | 1,475 | 2 | T/T | OOM recorded by Slurm | 05:25:10 | No final success marker or timings | `logs/job_49629886_4294967294.log`, `logs/resources_49629886_0.txt` |
| `49630695_2` | *A. clusiana* | 174 | 112 | T/T | OOM; 66 OOM kills | 01:35:32 | No final success marker or timings | `logs/job_49630695_2.log`, `logs/resources_49630695_2.txt` |
| `49842976_1` to `55020903_3` | Full-raster storage, worker and production tests | See main experiment table | See main experiment table | See main experiment table | See main experiment table | See main experiment table | See main experiment table | Main experiment table and cited sources |
| `55530303_[4-167]` | Replacement production array | Species 4 to 167 | 8 requested | F/F | Cancelled before R started | 1 to 16 s per task | CINECA prolog: insufficient or expired budget | `docs/work-in-progress/appunti.md`, "Esaurimento del budget DCGP" |
| `46403582` | Scope not recorded in consolidated notes | NA | NA | NA | Completed | 50:18:54 | Largest recorded single-job budget cost | `docs/work-in-progress/appunti.md`, "Job con il consumo maggiore" |

## Preliminary Spartaco measurements

These four runs were recorded manually before the Leonardo experiments. They are not controlled benchmarks. The source does not identify the code revision, container, hardware, input version or measurement method. The label `n_cells` is retained because its meaning is unresolved.

| Species | `n_cells` | PA | Repetitions | Runs | CPU | Formatting | Models | Future projection | Maximum RAM (GB) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| *Omalotheca hoppeana* | 681 | 10,000 | 10 | 10 | 5 | 1.9 h | 11.33 min | 3.65 min | 52.90 |
| *Omalotheca hoppeana* | 681 | 10,000 | 10 | 10 | 10 | 2.02 h | 7.74 min | 8.07 min | 56.16 |
| *Agrostis capillaris* | 100,000 | 5,000 | 5 | 5 | 5 | 32.25 min | 53.87 min | 3.73 min | 26.00 |
| *Agrostis capillaris* | 100,000 | 10,000 | 5 | 5 | 5 | 59.37 min | 1.6 h | 4.22 min | 29.96 |

Source: `docs/thesis/assets/tables/preliminary-spartaco.tex` and the provenance note in `docs/thesis/Chapters/3_CodeAsIs.tex`.

## Output validation

| Run group | Files | Size | Timing files | Success marker | Structural checks | Scientific caveat |
|---|---:|---:|---|---|---|---|
| `49844162_1` | 1,364 non-empty | about 7.2 GB | Present | Present | Current and eight future individual and ensemble directories; 127 model files | GLM, MAXNET and ensemble-metric warnings remain unresolved |
| `51485472_1`, `51494635_1`, `51485581_1` | 1,368 non-empty each | 7.3 to 7.4 GB each | Present | Present | Relative structures match after normalizing the BIOMOD2 numeric identifier; 1,143 projection writes each | Same unresolved warning classes |
| `51738981_1` | NA | NA | NA | Completion notified | Detailed validation not performed | Must not be used as complete evidence yet |
| `55020903_[1-3]` | 2,614 each | NA | Present according to campaign validation | Present | Three species directories were the only completed production outputs after the budget failure | Warning classes remain unresolved |

## Warnings and failures

### Repeated non-fatal warnings

| Warning class | Where observed | Current interpretation |
|---|---|---|
| Optional package `cito` not installed | Every local `job_*.log` that starts BIOMOD2 | Package-loading warning; no fatal effect recorded in these runs |
| `glm.fit: fitted probabilities numerically 0 or 1 occurred` | Most runs that reach modeling | Scientific validity still needs review |
| Integer coercion or overflow warnings | Most full-configuration runs, especially *A. capillaris* | Scientific and implementation impact still needs review |
| Missing values in evaluation summaries, including `no non-missing arguments to max` | Most runs that reach model evaluation | Metrics must be checked before scientific use |
| Binary or filtered transformation disabled for some ensemble outputs | Completed ensemble forecasts | BIOMOD2 informational warning; output interpretation must remain explicit |

### Fatal outcomes represented in the run tables

| Failure class | Example runs | Evidence |
|---|---|---|
| Node or worker OOM | `48075655_[1-5]`, `48607860_[1-5]`, `49629886`, `49630695_2`, `51739004_1`, `51739048_1` | Slurm OOM records and killed processes |
| Fork allocation failure without Slurm `OUT_OF_MEMORY` state | `49842976_1`, `49843592_1` | `mcfork(): unable to fork, possible reason: Cannot allocate memory` |
| Concurrent or stale output collision | `48325677_3`, `48418427_[3-5]` | `writeRaster` reports an existing file |
| Missing output path or invalid filename | `47574797_2`, `48873007_1`, `48873007_3` | `writeRaster` path, write failure or empty raster filename |
| Repeated SIGPIPE | `47510573_2`, `47510573_3` | Log retry loops followed by cancellation |
| Time limit | `bc71039`, `48873007_[2,4,5]`, `51756264_1`, `51756286_1` | Slurm time-limit messages or project notes |
| Administrative budget rejection before application start | `55530303_[4-167]` | CINECA prolog message; no R logs created |

## Campaign-level accounting

The production jobs requested all 494,000 MB available to a DCGP node. CINECA therefore charged each elapsed node-hour as 112 local core-hours, even though the jobs requested eight CPUs.

| Run | Elapsed | Approximate local hours | Slurm MaxRSS (GiB) |
|---|---:|---:|---:|
| `55020903_1` | 25:36:42 | 2,869 | about 316 |
| `55020903_2` | NA | NA | about 316 |
| `55020903_3` | 33:58:37 | 3,805 | about 291 |
| **Three-run total recorded in notes** | NA | **about 9,076** |  |

The three completed species consumed about 9,076 local hours. The notes contain a rough projection of about 496,000 additional local hours for the remaining 164 species, but that value is an estimate and is not presented as a measured runtime in this document.

Source: `docs/work-in-progress/appunti.md`, "Esaurimento del budget DCGP".

## File-transfer timings

No duration or throughput measurement was found for `scripts/3sync.sh`. The transfer procedure is documented, but its performance has not been measured.

| Operation | Route and method | Duration | Throughput | Source |
|---|---|---:|---:|---|
| Copy heavy data and `container/geospatial.sif` | Leonardo to Spartaco through Serviicola; `rclone copyto`, falling back to `scp -3` | NA | NA | `scripts/3sync.sh`, `docs/work-in-progress/appunti.md` |

## Source limitations

- Some early runs are known only by a historical commit reference or a descriptive log filename.
- Several resource files are empty. Their fields remain `NA`.
- The local log for `55020903_2` is incomplete, and the local log for `55020903_3` is absent. Their completion is documented in the consolidated notes and `_SUCCESS` checks performed on Leonardo.
- MaxRSS values marked "about" come from Slurm accounting transcribed into the project notes.
- The logs contain recurring scientific warnings. Successful process exit and `_SUCCESS` establish workflow completion, not scientific validity.
- No value in this document estimates missing runtime or transfer data.

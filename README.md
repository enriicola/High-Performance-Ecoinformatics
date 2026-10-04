# High-Performance Ecoinformatics

This repository contains the work for my MSc thesis on running and measuring a Species Distribution Modelling workflow on HPC systems. The workflow uses R and BIOMOD2 to study how climate change may affect Alpine grassland habitats.

The input dataset has 2,583,359 species-presence records for 167 species at 1 km resolution. For each species, the workflow calibrates five algorithms, builds two ensemble models, and projects them onto the current environment and eight future climate scenarios. The environmental rasters have approximately 64 million cells. *Galium anisophyllon* is the median species by occurrence count, with 5,936 records. The performance experiments use *Achillea atrata* because it has the largest set of comparable runs and validated outputs. The choice reflects the available experimental evidence; its statistical, geographical, and biological representativeness has not been assessed.

The goal is to reduce the complete analysis from X days to X hours while preserving correct and reproducible results.

## Credits

DISTAV supplied the occurrence CSV. The source collection combines [sPlot](https://www.idiv.de/research/projects/splot/) (Sabatini et al., 2021, [sPlotOpen version 0](https://idata.idiv.de/DDM/Data/ShowData/3474?version=0)), [Silene](https://silene.eu/), [GBIF](https://www.gbif.org/occurrence/download), and the [European Vegetation Archive](https://euroveg.org/eva-database/). The repository does not yet record the exact source versions, download dates, filtering procedure, or licence of the compiled table.

- [ ] Confirm the occurrence-data provenance and licence.
- climate variables are from ...
- soil variables are from ...
- TRI variables are from ...

## Usage

The `Makefile` provides shortcuts for environment setup, compilation, and remote cluster access. See the file for the full list of commands.

```bash
make git-setup   # enable the shared Git configuration
make container   # build the container
make thesis      # compile the thesis
make slides      # compile the slides
make leogin      # connect to CINECA's Leonardo
make sshpartaco  # connect to Spartaco
make unigin      # connect to the UniGe cluster
```

## Workers, cores and physical CPUs

A Leonardo DCGP node has two physical CPU packages, or sockets, with 56 physical cores each. On this partition, CINECA defines `--cpus-per-task=N` as an allocation of `N` physical cores to one Slurm task. It does not allocate `N` complete CPU packages.

BIOMOD2 uses `nb.cpu=N` to register up to `N` R worker processes. Slurm restricts the task to its allocated set of cores, and the Linux scheduler places the workers on those cores. A worker is not normally tied permanently to one core unless explicit affinity is configured. With `N` busy workers and `N` allocated cores, the available capacity is approximately one worker per core; the R driver and resource sampler briefly share the same allocation.

`OMP_NUM_THREADS` controls OpenMP threads inside each worker, not the number of BIOMOD2 workers. The launchers set `OMP_NUM_THREADS`, `OPENBLAS_NUM_THREADS`, and `MKL_NUM_THREADS` to `1`, limiting each worker to one compute thread in those runtimes. If these variables are unset, each runtime chooses its own default, often from the processors visible to the process. Linux schedules the threads after they have been created; it does not decide how many threads a library creates. This can produce nested parallelism, such as `N` BIOMOD2 workers each creating multiple native threads.

## TL;DR

These tables give a short record of comparable runs and their performance over time.

### *Achillea atrata* runs

Apart from the number of PA replicates (5 or 10), the runs use the same scientific settings:

- 10,000 pseudo-absences per replicate
- 5 cross-validation replicates
- 5 algorithms
- 2 ensembles
- 8 future scenarios
- 2 workers during ensemble phases in every run listed below

Storage is `keep.in.memory/do.stack` (`F` = `FALSE`, `T` = `TRUE`). For these runs, the Slurm CPU allocation equalled the worker count used for individual modelling and projection. Speedup and reduction are relative to the 4-worker PA = 5 F/F run. The asterisk identifies the PA = 10 cross-configuration comparison.

> How many workers reduce wall time without crashing the run?

| Run | PA reps | CPUs | Ensemble workers | Storage | Status | Wall time | Speedup vs 4 | Reduction | CPU-h | CPU allocation used | Slurm MaxRSS (GiB) |
|---|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|
| `49844162_1` | 5 | 4 | 2 | F/F | 0k | 22:34 | 1.000× | 0.0% | 71.15 | 78.8% | 260.94 |
| `51485472_1` | 5 | 4 | 2 | T/F | 0k | 22:22 | 1.009× | 0.9% | 70.68 | 79.0% | 264.69 |
| `51494635_1` | 5 | 6 | 2 | F/F | 0k | 17:51 | 1.264× | 20.9% | 72.95 | 68.1% | 258.95 |
| `51485581_1` | 5 | 8 | 2 | F/F | 0k | 15:06 | 1.495× | 33.1% | 72.51 | 60.0% | 278.67 |
| `55020903_1` | 10 | 8 | 2 | F/F | 0k | 25:37 | 0.881×* | −13.5%* | 140.65 | 68.6% | 316.16 |
| `51738981_1` | 5 | 16 | 2 | F/F | 0k | 10:21 | 2.179× | 54.1% | 74.75 | 45.1% | 464.77 |
| `51739048_1` | 5 | 32 | 2 | F/F | OOM | 01:40 | NA | NA | NA | NA | 481.16 |

Completed PA = 5 runs produced 7.18–7.35 GiB. The PA = 10 production run produced 13.98 GiB.

### Phase timings

The historical timing files record elapsed time only. They do not contain phase-level CPU, RAM or disk measurements. `CPUs` is the number of physical cores allocated by Slurm and the worker count used for individual models and projections; ensemble phases used two workers. PA replicates are listed in the run table above rather than repeated here.

| Run | CPUs | Formatting | Individual models | Ensemble models | Current projection | Current ensemble |
|---|---:|---:|---:|---:|---:|---:|
| `49844162_1` | 4 | 1h 15m 28s | 4m 9s | 2m 17s | 1h 57m 28s | 23m 42s |
| `51485472_1` | 4 | 1h 14m 50s | 4m 9s | 2m 17s | 1h 56m 29s | 24m 28s |
| `51494635_1` | 6 | 1h 16m 41s | 2m 56s | 2m 17s | 1h 25m 33s | 24m 12s |
| `51485581_1` | 8 | 1h 15m 31s | 2m 19s | 2m 18s | 1h 7m 38s | 24m 9s |
| `55020903_1` | 8 | 2h 29m 32s | 4m 28s | 9m 35s | 2h 0m 54s | 33m 29s |
| `51738981_1` | 16 | 1h 14m 45s | 1m 19s | 2m 20s | 36m 26s | 25m 17s |
| `51739048_1` | 32 | NA | NA | NA | Failed | NA |

Each future scenario used the model/projection worker count for its individual projection and two workers for its ensemble projection. The totals below sum the eight scenarios. `Loop overhead` is the time measured by the outer future-loop timer but not by the two BIOMOD2 call timers. It includes opening and combining the scenario rasters, deriving names, selecting the ensemble backend, recording timings, removing temporary objects, garbage collection, and loop bookkeeping. The archived evidence for `49844162_1` contains only the combined future total, so its split is left unknown.

| Run | CPUs | Future projections | Future ensembles | Loop overhead | Future total | Future share |
|---|---:|---:|---:|---:|---:|---:|
| `49844162_1` | 4 | NA | NA | NA | 18h 50m 19s | 83.5% |
| `51485472_1` | 4 | 15h 24m 16s | 3h 14m 35s | 8s | 18h 39m 0s | 83.4% |
| `51494635_1` | 6 | 11h 24m 52s | 3h 13m 56s | 8s | 14h 38m 56s | 82.1% |
| `51485581_1` | 8 | 8h 58m 26s | 3h 14m 42s | 8s | 12h 13m 17s | 81.0% |
| `55020903_1` | 8 | 16h 1m 21s | 4h 16m 47s | 9s | 20h 18m 17s | 79.3% |
| `51738981_1` | 16 | 4h 47m 7s | 3h 13m 39s | 8s | 8h 0m 55s | 77.4% |
| `51739048_1` | 32 | NA | NA | NA | NA | NA |

## TODOs

### Immediate

- [ ] gdal compression:
  - [ ] https://kokoalberti.com/articles/geotiff-compression-optimization-guide/
  - [ ] https://gdal.org/en/stable/drivers/raster/gtiff.html

- [ ] usare foreach::registerDoSEQ() solo se esegui le fasi R in modo ibrido (alcune seq alcune par, in modo da forzare le eventuali sessioni ereditate da source(...) sequenziali ad essere veramente seq)
- [ ] does it make sense to have the actual biomod2 code on every non-serviicola computer? keeping in mind that i downloaded on serviicola for develpment and llm porpuses, i don't this is useful to be downloaded also on the other computers
- [ ] rename HPC_Leonardo to High-Performance-Ecoinformatics (spartaco)
- [ ] manage all things inside right-now-todo and delete each file after each single inside step is done 1by1
- [x] Review comments in the active R pipelines: document scientific and data contracts, resource constraints, output ownership and non-obvious tradeoffs without narrating the code line by line.
- [ ] after having refactor the R code, add precise specifics and metrics with whom track precisely the progress, performances, hotspot, i/o, and whatnot
- [ ] add also resource (cpu/ram/disk) used to the tables 
- [ ] send a whatsapp msg as soon as the tables got updated telling the tables got updated with resources consumption
- [ ] find the species with the least occurrencies and meditate if running some tests with it on serviicola (ryzen 5, 32gb ram)
- [ ] if snowfall needs at least 2 species, should we adjust our project accordingly? (since rn we're improving execution times on a single specie bases)
- [ ] check if we can migrate R variables from double to float
- [ ] /home/ubuntu/.config/rclone/rclone.conf
- [ ] convert the input data to binary and keep them as binary instead of loading them everytime
- [ ] check disparità proiezione_corrente vs ensemble_corrente (soprattutto ensemble che resta costante, nonostante sia una costa sola, controllare se davvero non si può fare meglio di così)
- [x] Split future timings into individual projections, ensemble projections and loop overhead.
- [ ] ragionare se tirare fuori 10 seed per la formattazione iniziale e poi mergiare il 10% di ognuno
- [ ] alla fine, controllora perchè la 'formattazione' ci mette così tanto
- [ ] check the biomod2 version
- [ ] read and study the new article of new biomod2 also for latex purposes
- [ ] check if have to use biomod2 fron cran registry or source code
- [ ] add prof dell'amico as a collaborator to the repo

### Performance and hardware issues

- [ ] Controllare se alcuni problemi per cui non riesco a fare i test Run su Leonardo sono dovuti al container rocker e non alla ram
- [ ] Review the fatal failures catalogued in `docs/appunti.md#errori-fatali-e-arresti` against the current workflow; reproduce those still applicable, fix them at their source and add focused regression checks.
- [ ] Test whether one-worker F/F execution, the MAXNET blockwise path and a measured Terra memory budget can make the workflow viable on 32 GiB Serviicola; do not assume the full raster fits.
- [ ] Ask CINECA whether whole-step termination after a cgroup OOM and cgroup-v2 `memory.high` are available for these jobs.

### Thesis

- [ ] add the right credits for the input data to the 'Credits' section
- [ ] add also expected or estimated values in various projetions, tables and plots and graphs using dotted lines, i.e. a preliminary row-normalized runtime projection for a hypothetical execution of all 167 species using sequential I/O, sequential model execution and one worker. 
- [ ] produce the same thing as above using an actual sequential base execution and then derive the data for plots as `reference runtime / reference occurrences * species occurrences`, then sum the measured reference runtime and estimated values to obtain the projected sequential runtime for the complete dataset.
- [ ] Check whether any images from the [WGS84 Wikipedia article](https://it.wikipedia.org/wiki/WGS84) are needed for the thesis.
- [ ] Write and revise the chapters using verified results.
- [ ] NB: keep in mind and remmber to use the professor suggestions inside docs/thesis/main.tex after the end of the document
- [ ] Confirm the title, structure, abstract and scientific content with the supervisors.
- [ ] Replace supervisor, co-supervisor, examiner and dedication placeholders.
- [ ] Decide whether the abstract belongs in the main file or in `Chapters/abstract.tex`.
- [ ] Add figures and tables only when their data and captions are verifiable.
- [ ] Prepare the technical and short presentations.
- [ ] Consider automatic LaTeX compilation once the document structure is stable.
- [ ] Add a LaTeX command for writing comments and notes in red within the thesis.
- [ ] Choose the slide format and template, then prepare separate technical and short presentations.
- [ ] 1 hour long technical slides
- [ ] 15 minutes long non-technical slides

### Scientific validation

- [x] Verify that occurrence points and environmental rasters use the same CRS; expected: WGS84 / EPSG:4326. Verified on Leonardo inside the production container on 2026-09-08: all 18 environmental rasters report EPSG:4326 and have identical geometry. All 2,583,359 occurrence coordinates fall within the raster extent and align with its grid-cell centres within `1e-9` degrees, so no reprojection is required. The check is documented in the thesis and in `logs/crs_validation_2026-09-08.txt`.
- [ ] Check GLM, MAXNET and integer-overflow warnings.
- [ ] Check whether the explicit `scale.models = FALSE` parameter is still needed.
- [ ] Change evaluation output from text files to CSV.
- [ ] Verify the GCM and SSP acronyms used in the workflow documentation.
- [ ] Extract and document evaluation metrics, including TSS and AUC/ROC.
- [ ] Define which individual rasters to retain in addition to ensembles, metrics and metadata.
- [ ] Measure output sizes for several species before estimating total storage.
- [ ] Run the hotspot analysis, test parallel and vectorized approaches, and document its method, results, statistics and limitations.

### Leonardo campaign

- [ ] research if possible to run the analysis on serviicola with some memory guardrail or similar, since my server has only 32gb of ram, but i'd still like to use it
- [ ] Revalidate the 8-worker F/F reference after the R rewrite before retaining it as the production default; do not choose 16 workers without new memory-headroom evidence.
- [x] Validate the 16-worker test and its outputs before using it as evidence. The retrospective check confirmed final accounting, 464.77 GiB MaxRSS, phase timings, 1,364 non-empty species files, four root summaries, `_SUCCESS`, the current projection and all eight future scenarios.
- [ ] Design the complete campaign as one task per species, with at most three concurrent nodes.
- [ ] Decide how to handle failed species: write `_FAIL` for catchable errors, collect error context, and retry selectively or stop later waves.
- [ ] Evaluate shortest-job-first ordering without confusing it with a reduction in total cost.
- [ ] Record makespan, CPU-hours, MaxRSS, species status, phase timings and output validation.
- [ ] Evaluate a warning-only Slurm monitor based on live `sstat` and final `sacct` MaxRSS; do not cancel or resubmit jobs automatically.

### Workflow optimization

- [ ] Complete the full-raster comparison in `tests/test_maxnet_blockwise.R`, including runtime, MaxRSS and output equality.
- [ ] After the full-raster MAXNET check, benchmark a per-process Terra budget (`memmax`, `memfrac`, `threads`, `tempdir`) one change per run; test an R vector-heap cap only afterward.
- [ ] Update `tests/expected_output_foreach_species.txt` only when the output contract intentionally changes.
- [ ] write a test suite for the src code at `R/`, using (if reviewed as good or useful) `tests/test_output.R`.
- [ ] Move the POC integration test from `R/poc/test-smoke.R` to `tests/` once the POC layout is stable, preserving its container-based execution and exact output comparisons.
- [x] Verify whether splitting the script changes memory or runtime. Benchmark `49303754` found the split and monolithic versions equivalent under the tested conditions; the historical harness is recoverable from commit `3825368`.
- [ ] Measure I/O contention with multiple workers.
- [ ] Reduce recalculation and copying only when measurements justify it.
- [ ] Add timestamps to the relevant statements and phases in the R logs.
- [ ] Evaluate releasing RAM between phases; do not use disk automatically without measuring it.
- [ ] Decide whether to clean `data/output/` before every run and automate removal of stale output if needed.
- [ ] Consider `snowfall` only if the BIOMOD2 internal backend tests still require it.

### Infrastructure and study

- [ ] Complete and verify the rsync workflow between the local computer, Serviicola and Leonardo, including transfers between Linux and Spartaco.
- [ ] Document the complete CINECA login workflow from Linux.
- [ ] Decide how to handle the Git LFS/data-sharing issue: Forgejo or an rsync-based workflow.
- [ ] Remove credentials from the notes and purge them from Git history.
- [ ] Investigate slow Git operations on the HPC filesystem and decide whether large files need a different treatment.
- [ ] Clarify the differences between R output methods such as `message`, `print`, `cat` and `printf`.
- [ ] Finish `workflow-leo.sh`.
- [ ] Consolidate the old ensemble-modelling scripts after understanding their differences.
- [ ] Verify the CINECA project codes with Lucia: `IsCd6_SPECC` and `IscrC_SPECC`.
- [ ] Configure an R formatter and LSP, possibly with pre-commit.
- [ ] Keep the Makefile as a minimal wrapper and extend it only for recurring operational commands.
- [ ] Evaluate CUDA in Rocker and SonarQube support only if they become concrete project needs.
- [ ] Redirect container-definition output so that only errors and warnings are shown.
- [ ] If needed in September, request additional CINECA resources.
- [ ] Review SIMD/AVX and Mitchell Hashimoto's note.
- [ ] Finish the HPC exercises listed in `R/tmp/hello-world.R`.
- [ ] Consider `broom` only if it is needed for metric extraction.
- [ ] Clarify the “supermarket scheduling” idea before turning it into a requirement.
- [ ] Determine whether it can run Doom.
  - https://www.r-bloggers.com/2024/05/if-doom-runs-everywhere-it-must-run-on-shiny/
  - https://www.reddit.com/r/programming/comments/fjk4m4/doom_runs_on_everything/

### Graduation dates

- https://servizionline.unige.it/studenti/DOMANDALAUREA
- https://corsi.unige.it/corsi/11964/candidates-graduation-days-committees

- **14/10/2026** + 15/10/2026
- **21/12/2026** + 22/12/2026
- **18/02/2027** + 19/02/2027
- **22/03/2027** + 24/03/2027

- [ ] -30 calendar days from the graduation date the candidate sends the current version of their thesis to the examiner, keeping the supervisor in copy. The thesis must be nearly final at this point.
- [ ] -30 calendar days from the graduation date (possibly, before) the candidate, with the supervisor's help, completes the degree application and fills out the AlmaLaurea form. Errors in filling them out must be solved by the candidate with the support of the supervisor and may cause the graduation date to be postponed to the next session. It is essential that the candidate, if in doubt, seeks help from the supervisor.
- [ ] -20 calendar days from the graduation date the supervisor approves/rejects the application.
- [ ] -15 calendar days from the graduation date (possibly, before) the candidate must have all marks registered.
- [ ] -15 calendar days from the graduation date (possibly, before) the candidate uploads the final version of the thesis through the official service made available to students.
- [ ] -14 calendar days from the graduation date the supervisor approves/rejects the document uploaded by the candidate.
- [ ] -14 calendar days from the graduation date the supervisor shares their evaluation of the thesis work with the examiner and the Master Thesis Working Group by filling a form. In case of more supervisors, they must agree on a shared evaluation: only one evaluation must be inserted via the form by one of the supervisors. 
- [ ] -14 calendar days from the graduation date the examiner (also named reviewer, or correlatore in Italian), who chairs the technical examination committee, communicates the date and place of the technical exam to the candidate, the supervisor and to the technical committee members.
- [ ] Between -14 days and -2 days from the first date of the session: the technical exam takes place. The technical exam is required only to students enrolled from 2023/2024 onwards. Students enrolled before that academic year will prepare a longer presentation for the Thesis Committee, and will face no technical exam:
	- the candidate defends their work: the expected duration of the exam is 20-25 minutes of presentation followed by questions and defense;
	- once the exam has taken place, the examiner communicates the mark to the candidate and to the Master Thesis Working Group by filling a form.

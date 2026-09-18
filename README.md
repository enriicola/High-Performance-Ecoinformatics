# High-Performance Ecoinformatics

This repository contains my MSc thesis project. The project studies how climate change may affect Alpine grassland habitats using Species Distribution Models implemented in R with BIOMOD2.

The dataset contains 2,583,359 species-presence records for 167 species at 1 km resolution. For each species, the workflow calibrates 5 algorithms, builds 2 ensemble models, and projects them over the current environment and 8 future climate scenarios. The environmental rasters contain approximately 64 million cells. 

My work focuses on making this workflow executable and measurable on a HPC unit. In particular, my goal is to make the complete ecology analysis much faster: it currently takes X days, and I am working to reduce its execution time to X hours without compromising the correctness or reproducibility of the results.

## Credits

The input data are from:

- species dataset is from ... [CHELSA Climate](https://www.chelsa-climate.org). (?)
- climate variables are from ...
- soil variables are from ...
- TRI variables are from ...

## Usage (TO BE UPDATED)

This project uses a `Makefile` to simplify environment setup, compilation, and remote cluster access, see the `Makefile` for additional commands.

Enable the common git config setup:

```bash
make git-setup
```

Build the container, compile the thesis locally, or compile the slides:

```bash
make container
make thesis
make slides
```

Connect to one on the HPC unit:

```bash
make leogin #CINECA's Leonardo
make sshpartaco #Spartaco pc
make unigin #UniGe cluster
```

Sync everything:

```bash
make omni-sync
```

## TL;DR

this section is an extremely brief archive of every execution (tables and related contents), showcasing the performance improvements over time.

| lorem | ipsum | dolores | lorem | ipsum | dolores| lorem | ipsum |
|---|---:|---|---:|---:|---:|---:|---|
| `49844162_1` | 4 | completed | 22:33:45 | 1,000× | 0,0% | 260,94 | notes ...|
| `51494635_1` | 6 | failed | 17:50:53 | 1,264× | 20,9% | 258,95 | notes ... |
| `51485581_1` | 8 | to be done | 15:05:30 | 1,495× | 33,1% | 278,67 | notes ... |
| `51738981_1` | 16 | lorem | 10:21:23 | 2,179× | 54,1% | 464,77 | notes ... |
| `51739048_1` | 32 | OOM | 01:39:54 | NA | NA | 481,16 | notes ... |

## Situantionship schema

```text
                          GitHub ----------------------------------------+
                             ^                                           |
                             |                               'git pull' foreach host
                             |                                           |
                             v                   +--> Leonardo <---------+
 John Doe     SSH       Serviicola       SSH     |                       |
   [pc 1] ----+-----> [orchestratore] -----------+--> Cluster UniGe <----+
              |              |          rclone   |                       |
   [pc 2] ----+              |                   +--> ...   <------------+
              |              |                   |                       |
   [pc n] ----+            output                +--> HPComputer n <-----+
                             |
                             v
                         Spartaco
                    [archivio finale]
```

## TODOs

### immediate

- [ ] does it make sense to have the actual biomod2 code on every non-serviicola computer? keeping in mind that i downloaded on serviicola for develpment and llm porpuses, i don't this is useful to be downloaded also on the other computers
- [ ] rename HPC_Leonardo to High-Performance-Ecoinformatics (spartaco)
- [ ] manage all things inside right-now-todo and delete each file after each single inside step is done 1by1
- [ ] Comment well every .R file
- [ ] after having refactor the R code, add precise specifics and metrics with whom track precisely the progress, performances, hotspot, i/o, and whatnot
- [ ] add also resource (cpu/ram/disk) used to the tables 
- [ ] send a whatsapp msg as soon as the tables got updated telling the tables got updated with resources consumption
- [ ] find the species with the least occurrencies and meditate if running some tests with it on serviicola (ryzen 5, 32gb ram)
- [ ] check n_cpu
- [ ] if snowfall needs at least 2 species, should we adjust our project accordingly? (since rn we're improving execution times on a single specie bases)
- [ ] check if we can migrate R variables from double to float
- [ ] /home/ubuntu/.config/rclone/rclone.conf
- [ ] convert the input data to binary and keep them as binary instead of loading them everytime
- [ ] check disparità proiezione_corrente vs ensemble_corrente (soprattutto ensemble che resta costante, nonostante sia una costa sola, controllare se davvero non si può fare meglio di così)
- [ ] splittare 'quota futura' come il 'corrente' in proiezione e ensemble
- [ ] ragionare se tirare fuori 10 seed per la formattazione iniziale e poi mergiare il 10% di ognuno
- [ ] alla fine, controllora perchè la 'formattazione' ci mette così tanto
- [ ] check the biomod2 version
- [ ] read and study the new article of new biomod2 also for latex purposes
- [ ] check if have to use biomod2 fron cran registry or source code
- [ ] add prof dell'amico as a collaborator to the repo

### performance hw issue (OOM, fork errors, etc)

- [ ] Controllare se alcuni problemi per cui non riesco a fare i test Run su Leonardo sono dovuti al container rocker e non alla ram
- [ ] Review the fatal failures catalogued in `docs/review/2.local-log-metadata.md#errori-fatali-e-arresti` against the current workflow; reproduce those still applicable, fix them at their source and add focused regression checks.
- [ ] research if possible to run the analysis on serviicola with some memory guardrail or similar, since my server has only 32gb of ram, but i'd still like to use it

### Thesis

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

- [ ] Use the 4-, 6- and 8-worker results to choose and document a configuration.
- [x] Validate the 16-worker test and its outputs before using it as evidence. The retrospective check confirmed final accounting, 464.77 GiB MaxRSS, phase timings, 1,364 non-empty species files, four root summaries, `_SUCCESS`, the current projection and all eight future scenarios.
- [ ] Design the complete campaign as one task per species, with at most three concurrent nodes.
- [ ] Decide how to handle failed species: collect errors, retry selectively or stop later waves.
- [ ] Evaluate shortest-job-first ordering without confusing it with a reduction in total cost.
- [ ] Record makespan, CPU-hours, MaxRSS, species status, phase timings and output validation.
- [ ] Evaluate a Slurm monitoring script for array jobs and their logs.

### Workflow optimization

- [ ] Complete the full-raster comparison in `tests/test_maxnet_blockwise.R`, including runtime, MaxRSS and output equality.
- [ ] Update `tests/expected_output_foreach_species.txt` only when the output contract intentionally changes.
- [ ] write a test suite for the src code at `R/`, using (if reviewed as good or useful) `tests/test_output.R`.
- [ ] Move the POC integration test from `R/poc/test-smoke.R` to `tests/` once the POC layout is stable, preserving its container-based execution and exact output comparisons.
- [x] Verify whether splitting the script changes memory or runtime. Benchmark `49303754` found the split and monolithic versions equivalent under the tested conditions; the historical harness is recoverable from commit `3825368`.
- [ ] Measure I/O contention with multiple workers.
- [ ] Reduce recalculation and copying only when measurements justify it.
- [ ] Pass the Slurm CPU count to R through `BIOMOD_NCPU`.
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

### graduation dates

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

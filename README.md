# High-performance ecoinformatics

This repository contains my MSc thesis project, developed through a collaboration between DIBRIS and DISTAV at the University of Genoa. The project studies how climate change may affect Alpine grassland habitats using Species Distribution Models implemented in R with BIOMOD2.

The working dataset contains 2,583,359 species-presence records for 167 species at 1 km resolution. For each species, the workflow calibrates five algorithms, builds two ensemble models, and projects them over the current environment and eight future climate scenarios. The environmental rasters contain approximately 64 million cells. The climate and soil input data were obtained from [CHELSA Climate](https://www.chelsa-climate.org).

My work focuses on making this workflow executable and measurable on the CINECA Leonardo supercomputer. In particular, my goal is to make the complete analysis much faster: it currently takes X days, and I am working to reduce its execution time to X hours without compromising the correctness or reproducibility of the results.

The Git repository and `container/geospatial.sif` are kept on Serviicola, Leonardo and Spartaco. The container image is ignored by Git. Large inputs and generated model output under `data/` are also ignored; they are stored on Leonardo and copied to Spartaco with `make 3sync`. The same command copies the container from Leonardo to Spartaco through Serviicola.

Git tracks the two small input CSV files and the textual summaries written directly under `data/output/`. `scripts/3sync.sh` transfers the remaining data without deleting files from the destination.

## Usage

Enable the repository hooks after cloning:

```bash
git config core.hookspath .githooks
```

Build the container, compile the thesis locally, or compile the slides:

```bash
make container
make thesis
make slides
```

Connect to Leonardo and submit a species task:

```bash
make leogin
make sbatch
```

Monitor submitted jobs with:

```bash
squeue --me
tail -f logs/job_<job-id>_<task-id>.log
```

## TODOs

### relator prof todos

- [ ] tempistiche tabelle con tutti gli step e tutte le variabili
- [ ] scrivere nella bozza della tesi una belle descrizione della tesi, perchè etc, presentare i risultati
- [ ] capitolo container e worflow, risultati e difficoltà su leonardo
- [ ] domande sul codice
- [ ] serviranno 3 versioni del codice R: 
    1. I/O sequenziale e modelli sequenziale
    2. I/O sequenziale e modelli parallelo
    3. I/O paralleli e modelli parallelo

### orphaned todos

- [ ] research if possible to run the analysis on serviicola with some memory guardrail or similar, since my server has only 32gb of ram, but i'd still like to use it
- [ ] same thing for spartaco, we could try this insane idea to distribute the analysis between 3 servers, but idk, could be too much overhead

- [x] aggiungere i criteri di minimalismo e indicazioni di scarse dipendenze
- [ ] Commentare come si deve e per bene sia il codice R e anche il resto
- [ ] Controllare se alcuni problemi per cui non riesco a fare i test Run su Leonardo sono dovuti al container rocker e non alla ram
- [ ] dopo una baseline solidissima, Aggiungere delle specifiche con cui tracciare dei precisissimi progressi al codice e alle sue performance, hotspot, i/o, and whatnot
- [ ] valutare se aggiungere all'agent.md di dire a pi di usare Chrome per fare degli screenshot per controllarsi da solo (e anche farsi controllare da me)
- [ ] Riassumere questo video e prenderne degli appunti della trascrizione di buone pratiche di programmazione con i coding agent da aggiungere alla tesi: <https://www.youtube.com/watch?v=TJ6ruN-o0PA>

### wip

- [ ] 01a00bf8-1198-7cb9-b45e-aeb25163cebd: researching and solving the OOM errors + blockwise-override trial run (old session)
- [ ] 01a03831-9d4c-7366-8a2b-fa1f748f70c1: declutter: + finish Leonardo stuff and runs after maintenance (4 september 0800)

### Thesis

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

- [ ] Verify that occurrence points and environmental rasters use the same CRS; expected: WGS84 / EPSG:4326. In the container, check with `terra::crs(terra::rast("data/input/climate_vars/baseline/PC1.tif"), describe = TRUE)$code`; reproject the points if necessary and document the check in the thesis.
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
- [ ] Validate the 16-worker test and its outputs before using it as evidence.
- [ ] Design the complete campaign as one task per species, with at most three concurrent nodes.
- [ ] Decide how to handle failed species: collect errors, retry selectively or stop later waves.
- [ ] Evaluate shortest-job-first ordering without confusing it with a reduction in total cost.
- [ ] Record makespan, CPU-hours, MaxRSS, species status, phase timings and output validation.
- [ ] Evaluate a Slurm monitoring script for array jobs and their logs.

### Workflow optimization

- [ ] Complete the full-raster comparison in `tests/test_maxnet_blockwise.R`, including runtime, MaxRSS and output equality.
- [ ] Update `tests/expected_output_foreach_species.txt` only when the output contract intentionally changes.
- [ ] write a test suite for the src code at `R/`, using (if reviewed as good or useful) `tests/test_output.R`.
- [ ] Verify whether splitting the script changes memory, parallelism or reproducibility.
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

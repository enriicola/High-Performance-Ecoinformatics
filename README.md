# High-performance ecoinformatics

This repository contains my MSc thesis project, developed through a collaboration between DIBRIS and DISTAV at the University of Genoa. The project studies how climate change may affect Alpine grassland habitats using Species Distribution Models implemented in R with BIOMOD2.

The working dataset contains 2,583,359 species-presence records for 167 species at 1 km resolution. For each species, the workflow calibrates five algorithms, builds two ensemble models, and projects them over the current environment and eight future climate scenarios. The environmental rasters contain approximately 64 million cells. The climate and soil input data were obtained from [CHELSA Climate](https://www.chelsa-climate.org).

My work focuses on making this workflow executable and measurable on the CINECA Leonardo supercomputer. In particular, my goal is to make the complete analysis much faster: it currently takes X days, and I am working to reduce its execution time to X hours without compromising the correctness or reproducibility of the results.

Input rasters and generated model output are not stored in Git because they occupy several gigabytes. They are kept on Leonardo and backed up on Spartaco. The repository is cloned on all three computers, while heavy files under `data/` and `container/geospatial.sif` are synchronized between Leonardo and Spartaco through Serviicola with `make 3sync`.

The output is split between small textual files (`*.txt`), which are tracked by Git, and large raster/model files, which are transferred with `make 3sync` through `scripts/3sync.sh`.

## Usage

Enable the repository hooks after cloning:

```bash
git config core.hookspath .githooks
```

Build the container or compile thesis locally:

```bash
make container
make thesis
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

### Thesis

- [ ] Write and revise the chapters using verified results.
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

- [ ] Complete the blockwise MAXNET comparison on the full raster.
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

# PROGRESS.md — Project Status & LLM Memory

This file tracks the current state of **biomod++**, completed features, and upcoming tasks. It serves as a persistent memory for LLMs to understand the project's evolution.

## 🚀 Project Status
- **Current Phase**: Implementation & Local Validation.
- **Goal**: Finalizing the ensemble modelling pipeline for the Master's thesis.

## 🧠 Core Context (Memory)
- **Technologies**: R (`biomod2`, `terra`), Apptainer, SLURM (Cineca Leonardo).
- **Key Data**: PCA-derived bioclimatic variables (Baseline & Future), Species occurrence data (62k+ rows).
- **Environment**: Containerized execution (`container.sif`) is mandatory for consistency.

## ✅ Completed Tasks
- [x] Initial project setup and directory structure.
- [x] Apptainer definition file (`container.def`) created and tested.
- [x] Simulation script (`simulation.r`) baseline implementation.
- [x] SLURM job submission script (`scripts/job.sh`) configured for Leonardo.
- [x] Renamed `test.r` to `simulation.r` for clarity.

## 🛠 Active Tasks (In Progress)
- [ ] Refinement of `simulation.r` for performance optimization.
- [ ] Integration of topographic roughness index (TRI) layers.
- [ ] Validation of PCA future scenario projections.

## 📋 Backlog (Future)
- [ ] Full HPC run on Cineca Leonardo.
- [ ] Metric extraction (TSS, AUC, etc.) and visualization.
- [ ] Thesis document (`thesis.tex`) finalization.

## ⚠️ Known Issues / Notes
- Always use `TEST_N_ROWS` for local debugging to avoid long execution times.
- Ensure `make.names()` is used for all layer names in formulas.

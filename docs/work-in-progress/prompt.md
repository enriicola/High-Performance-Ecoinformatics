# Operational handoff

Use this file when resuming work on the BIOMOD2 campaign or the three-host workflow.

## Repository and hosts

- GitHub has one branch: `main`.
- Serviicola (`/home/ubuntu/tesi`), Leonardo (`/leonardo_work/IscrC_SPECC`) and Spartaco (`F:\HPC_Leonardo`) each keep a Git clone and `container/geospatial.sif`.
- Git ignores the container image. It tracks two small input CSV files and root-level `data/output/*.txt`.
- Heavy inputs and raster/model output under `data/` are ignored by Git and stored on Leonardo and Spartaco, not on Serviicola.
- `make 3sync` copies `data/` and the container from Leonardo to Spartaco through Serviicola without deleting destination files. Serviicola keeps its own copy of the container but not the heavy data. Use `make 3sync ARGS="<relative-path>"` for one path.
- Git LFS is not used.

## Campaign state

- Array tasks `55020903_1`, `_2` and `_3` completed; each has `_SUCCESS`.
- Task 3 (`Agrostis.capillaris`) finished on 2026-09-02 at 03:52:58 after 1d 9h 58m 34s.
- Old tasks `55020903_[4-167]` are held and must not be released.
- Replacement array `55530303_[4-167%3]` is pending because of maintenance.
- Leonardo maintenance runs from 2026-09-02 08:00 to 2026-09-04 08:00.
- The QoS allows at most three concurrent nodes; each array task processes one species on one node.

## Next operations

1. After maintenance, verify `squeue`, task 3 state and `_SUCCESS` from tmux window `tesi:1:leo`.
2. Re-clone GitHub metadata on Leonardo while preserving `data/`, `logs/` and `container/geospatial.sif`.
3. Synchronize `container/geospatial.sif` and completed campaign output to Spartaco.
4. Remove the held old array only after confirming the replacement array covers tasks 4–167.
5. Verify every completed species using `_SUCCESS`, file counts, sizes and logs; update `docs/run-manifest.md`.

## Guardrails

- Start responses with `Enrico` and communicate in Italian.
- Use `tmux send-keys` on `tesi:1:leo` for Leonardo commands.
- Inspect pane state before sending commands and restore log monitoring afterward.
- Require explicit approval before changing or cancelling Slurm jobs.
- Commit only task-related files; the main worktree may contain unrelated thesis edits.

Detailed scientific notes are in `docs/thesis/Chapters/notes.tex`; open work is in the `TODO` section of `README.md`; data layout is in `data/README.md`.

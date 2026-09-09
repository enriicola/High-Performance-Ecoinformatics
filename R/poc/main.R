#!/usr/bin/env Rscript

# Throwaway proof of concept for comparing execution profiles. The scientific
# values are provisional and live in config.R so every profile uses the same set.
options(warn = 1)
Sys.setenv(
  OMP_NUM_THREADS = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1"
)

`%||%` <- function(value, fallback) {
  if (is.null(value)) fallback else value
}

abort <- function(...) {
  stop(paste0(...), call. = FALSE)
}

script_args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", script_args, value = TRUE)
script_path <- if (length(script_arg) == 1L) {
  sub("^--file=", "", script_arg)
} else {
  file.path(getwd(), "R/poc/main.R")
}
script_dir <- dirname(normalizePath(script_path))
repo_root <- normalizePath(file.path(script_dir, "../.."))

print_help <- function() {
  cat(
    "Usage: Rscript R/poc/main.R [options]\n\n",
    "Profiles:\n",
    "  --variant=sequential_io_sequential_models\n",
    "  --variant=sequential_io_parallel_models\n",
    "  --variant=parallel_io_parallel_models\n\n",
    "Cumulative aliases:\n",
    "  --sequential     reset to sequential I/O and one BIOMOD2 worker\n",
    "  --parallel       enable the configured BIOMOD2 workers\n",
    "  --parallel-io    copy input and output files concurrently\n",
    "  --snowfall       distribute independent species with Snowfall\n\n",
    "Explicit overrides:\n",
    "  --config=PATH\n",
    "  --io=sequential|parallel\n",
    "  --models=sequential|biomod2\n",
    "  --species-backend=direct|snowfall\n",
    "  --model-workers=N --io-workers=N --snowfall-workers=N\n",
    "  --species=1,2,... --run-id=NAME\n",
    "  --dry-run        print resolved state without loading BIOMOD2\n",
    "  --help\n",
    sep = ""
  )
}

parse_positive_integer <- function(value, option) {
  parsed <- suppressWarnings(as.integer(value))
  if (is.na(parsed) || parsed < 1L || as.character(parsed) != value) {
    abort(option, " requires a positive integer")
  }
  parsed
}

parse_cli <- function(args) {
  out <- list(
    config = NULL,
    variant = NULL,
    sequential = FALSE,
    parallel = FALSE,
    parallel_io = FALSE,
    snowfall = FALSE,
    io = NULL,
    models = NULL,
    species_backend = NULL,
    model_workers = NULL,
    io_workers = NULL,
    snowfall_workers = NULL,
    species_indices = NULL,
    run_id = NULL,
    dry_run = FALSE,
    help = FALSE
  )

  for (arg in args) {
    if (arg == "--sequential") {
      out$sequential <- TRUE
    } else if (arg == "--parallel") {
      out$parallel <- TRUE
    } else if (arg == "--parallel-io") {
      out$parallel_io <- TRUE
    } else if (arg == "--snowfall") {
      out$snowfall <- TRUE
    } else if (arg == "--dry-run") {
      out$dry_run <- TRUE
    } else if (arg %in% c("--help", "-h")) {
      out$help <- TRUE
    } else if (startsWith(arg, "--config=")) {
      out$config <- sub("^--config=", "", arg)
    } else if (startsWith(arg, "--variant=")) {
      out$variant <- sub("^--variant=", "", arg)
    } else if (startsWith(arg, "--io=")) {
      out$io <- sub("^--io=", "", arg)
    } else if (startsWith(arg, "--models=")) {
      out$models <- sub("^--models=", "", arg)
    } else if (startsWith(arg, "--species-backend=")) {
      out$species_backend <- sub("^--species-backend=", "", arg)
    } else if (startsWith(arg, "--model-workers=")) {
      value <- sub("^--model-workers=", "", arg)
      out$model_workers <- parse_positive_integer(value, "--model-workers")
    } else if (startsWith(arg, "--io-workers=")) {
      value <- sub("^--io-workers=", "", arg)
      out$io_workers <- parse_positive_integer(value, "--io-workers")
    } else if (startsWith(arg, "--snowfall-workers=")) {
      value <- sub("^--snowfall-workers=", "", arg)
      out$snowfall_workers <- parse_positive_integer(value, "--snowfall-workers")
    } else if (startsWith(arg, "--species=")) {
      values <- strsplit(sub("^--species=", "", arg), ",", fixed = TRUE)[[1]]
      if (length(values) == 0L || any(!grepl("^[1-9][0-9]*$", values))) {
        abort("--species requires comma-separated positive integers")
      }
      out$species_indices <- as.integer(values)
    } else if (startsWith(arg, "--run-id=")) {
      out$run_id <- sub("^--run-id=", "", arg)
      if (!grepl("^[A-Za-z0-9._-]+$", out$run_id)) {
        abort("--run-id may contain only letters, digits, dot, underscore and hyphen")
      }
    } else {
      abort("Unknown option: ", arg)
    }
  }
  out
}

make_absolute <- function(path, root, must_work = FALSE) {
  candidate <- if (startsWith(path, "/")) path else file.path(root, path)
  normalizePath(candidate, mustWork = must_work)
}

profile_state <- function(variant) {
  switch(variant,
    sequential_io_sequential_models = list(
      io = "sequential", models = "sequential", species_backend = "direct"
    ),
    sequential_io_parallel_models = list(
      io = "sequential", models = "biomod2", species_backend = "direct"
    ),
    parallel_io_parallel_models = list(
      io = "parallel", models = "biomod2", species_backend = "direct"
    ),
    abort("Unknown workflow variant: ", variant)
  )
}

canonical_variant <- function(state) {
  if (state$species_backend == "direct" && state$io == "sequential" && state$models == "sequential") {
    "sequential_io_sequential_models"
  } else if (state$species_backend == "direct" && state$io == "sequential" && state$models == "biomod2") {
    "sequential_io_parallel_models"
  } else if (state$species_backend == "direct" && state$io == "parallel" && state$models == "biomod2") {
    "parallel_io_parallel_models"
  } else {
    paste0("io-", state$io, "_models-", state$models, "_species-", state$species_backend)
  }
}

validate_choice <- function(value, choices, option) {
  if (!value %in% choices) {
    abort(option, " must be one of: ", paste(choices, collapse = ", "))
  }
}

cli <- parse_cli(commandArgs(trailingOnly = TRUE))
if (cli$help) {
  print_help()
  quit(status = 0L)
}

config_path <- cli$config %||% file.path(script_dir, "config.R")
config_path <- make_absolute(config_path, repo_root, must_work = TRUE)
cfg <- dget(config_path)
if (!is.list(cfg) || !all(c("variant", "paths", "runtime", "species_indices", "science") %in% names(cfg))) {
  abort("Configuration must define variant, paths, runtime, species_indices and science")
}

variant <- cli$variant %||% cfg$variant
state <- profile_state(variant)

# Alias flags are cumulative and deterministic, regardless of CLI order.
if (cli$sequential) {
  state <- list(io = "sequential", models = "sequential", species_backend = "direct")
}
if (cli$parallel) {
  state$models <- "biomod2"
}
if (cli$parallel_io) {
  state$io <- "parallel"
}
if (cli$snowfall) {
  state$species_backend <- "snowfall"
}

# Explicit axis overrides take precedence over aliases.
state$io <- cli$io %||% state$io
state$models <- cli$models %||% state$models
state$species_backend <- cli$species_backend %||% state$species_backend
validate_choice(state$io, c("sequential", "parallel"), "--io")
validate_choice(state$models, c("sequential", "biomod2"), "--models")
validate_choice(state$species_backend, c("direct", "snowfall"), "--species-backend")

configured_model_workers <- cli$model_workers %||% cfg$runtime$model_workers
configured_io_workers <- cli$io_workers %||% cfg$runtime$io_workers
configured_snowfall_workers <- cli$snowfall_workers %||% cfg$runtime$snowfall_workers
model_workers <- if (state$models == "sequential") 1L else as.integer(configured_model_workers)
io_workers <- if (state$io == "sequential") 1L else as.integer(configured_io_workers)
snowfall_workers <- if (state$species_backend == "direct") 1L else as.integer(configured_snowfall_workers)
species_indices <- unique(cli$species_indices %||% as.integer(cfg$species_indices))

for (entry in list(
  model_workers = model_workers,
  io_workers = io_workers,
  snowfall_workers = snowfall_workers,
  seed = cfg$runtime$seed
)) {
  if (length(entry) != 1L || is.na(entry) || entry < 1L) {
    abort("Worker counts and seed must be positive integers")
  }
}
if (length(species_indices) == 0L || any(is.na(species_indices)) || any(species_indices < 1L)) {
  abort("species_indices must contain positive integers")
}
if (state$species_backend == "snowfall" && length(species_indices) < 2L) {
  abort("Snowfall mode requires at least two species indices")
}
if (state$io == "parallel" && .Platform$OS.type != "unix") {
  abort("Parallel file staging in this POC requires a Unix-like system")
}

allocated_cpus <- suppressWarnings(as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "")))
peak_workers <- max(io_workers, model_workers * snowfall_workers)
if (!is.na(allocated_cpus) && peak_workers > allocated_cpus) {
  abort(
    "Resolved worker count ", peak_workers,
    " exceeds SLURM_CPUS_PER_TASK=", allocated_cpus
  )
}

label <- canonical_variant(state)
input_source <- make_absolute(cfg$paths$input_dir, repo_root, must_work = FALSE)
output_root <- make_absolute(cfg$paths$output_dir, repo_root, must_work = FALSE)
scratch_root <- make_absolute(cfg$paths$scratch_dir, repo_root, must_work = FALSE)
job_id <- Sys.getenv("SLURM_JOB_ID", "local")
task_id <- Sys.getenv("SLURM_ARRAY_TASK_ID", "0")
experiment_id <- cli$run_id %||% Sys.getenv("POC_RUN_ID", paste(job_id, task_id, sep = "_"))
if (!grepl("^[A-Za-z0-9._-]+$", experiment_id)) {
  abort("POC_RUN_ID may contain only letters, digits, dot, underscore and hyphen")
}
scratch_id <- paste(label, experiment_id, Sys.getpid(), sep = "_")
scratch_run <- file.path(scratch_root, scratch_id)
staged_input <- file.path(scratch_run, "input")
work_output <- file.path(scratch_run, "output")
final_output <- file.path(output_root, label, experiment_id)

git_executable <- Sys.which("git")
source_revision <- NA_character_
source_dirty <- NA
if (nzchar(git_executable)) {
  source_revision <- tryCatch(
    system2(git_executable, c("-C", shQuote(repo_root), "rev-parse", "HEAD"), stdout = TRUE),
    error = function(error) NA_character_
  )
  source_status <- tryCatch(
    system2(git_executable, c("-C", shQuote(repo_root), "status", "--porcelain"), stdout = TRUE),
    error = function(error) NA_character_
  )
  source_dirty <- if (all(is.na(source_status))) NA else length(source_status) > 0L
}

resolved <- list(
  config = config_path,
  requested_variant = variant,
  resolved_variant = label,
  experiment_id = experiment_id,
  source_revision = source_revision,
  source_dirty = source_dirty,
  io = state$io,
  models = state$models,
  species_backend = state$species_backend,
  model_workers = model_workers,
  ensemble_workers = min(model_workers, 2L),
  io_workers = io_workers,
  snowfall_workers = snowfall_workers,
  species_indices = species_indices,
  seed = as.integer(cfg$runtime$seed),
  input_source = input_source,
  scratch_run = scratch_run,
  final_output = final_output,
  scientific_configuration = cfg$science
)
cat("Resolved POC configuration:\n")
print(resolved)

if (cli$dry_run) {
  quit(status = 0L)
}

required_packages <- c("biomod2", "terra", "gbm", "mda", "maxnet", "randomForest", "doParallel")
if (state$species_backend == "snowfall") {
  required_packages <- c(required_packages, "snowfall")
}
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0L) {
  abort("Missing R packages: ", paste(missing_packages, collapse = ", "))
}
suppressPackageStartupMessages({
  library(biomod2)
  library(terra)
  library(gbm)
  library(mda)
  library(randomForest)
})
resolved$package_versions <- setNames(
  vapply(required_packages, function(package) as.character(packageVersion(package)), character(1)),
  required_packages
)

source(file.path(script_dir, "helpers.R"))
source(file.path(script_dir, "1_formatting_and_cv.R"))
source(file.path(script_dir, "2_individual_modeling.R"))
source(file.path(script_dir, "3_ensemble_modeling_and_evaluation.R"))
source(file.path(script_dir, "4_model_projections.R"))
source(file.path(script_dir, "5_ensemble_forecasting.R"))
source(file.path(script_dir, "6_future_scenario_loop.R"))

run_species <- function(entry, run_cfg, input_dir, output_dir) {
  old_working_directory <- getwd()
  on.exit(setwd(old_working_directory), add = TRUE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  setwd(output_dir)

  species_name <- entry$species_name
  species_seed <- as.integer(run_cfg$seed + entry$index - 1L)
  set.seed(species_seed)
  cat(
    "POC species =", species_name,
    "| index =", entry$index,
    "| occurrences =", nrow(entry$rows),
    "| seed =", species_seed,
    "| model workers =", run_cfg$model_workers, "\n"
  )

  species_dir <- file.path(output_dir, species_name)
  if (dir.exists(species_dir)) {
    unlink(species_dir, recursive = TRUE)
  }

  current_environment <- load_environment(input_dir, run_cfg$science$raster_names)
  terrain <- current_environment[[3]]
  soil <- current_environment[[4:5]]
  future_scenarios <- list_future_scenarios(input_dir, run_cfg$science$future_limit)
  timings <- list()

  # Step 1: format occurrences and generate pseudo-absences.
  started <- Sys.time()
  formatted <- step_formatting(
    entry, run_cfg, current_environment, species_name, species_seed
  )
  timings$formatting <- seconds_since(started)

  # Step 1b: build the deterministic calibration table.
  # BIOMOD2 4.3-4-5 resets the random split with set.seed(NULL). Build the
  # random calibration table explicitly so every execution profile reuses the
  # same rows. Other CV strategies stay outside this proof of concept.
  started <- Sys.time()
  calibration_lines <- step_cross_validation(
    formatted, run_cfg, species_name, species_seed
  )
  timings$cross_validation <- seconds_since(started)

  # Step 2: fit the individual models.
  started <- Sys.time()
  models <- step_modeling(
    formatted, calibration_lines, entry, run_cfg, species_seed
  )
  timings$modeling <- seconds_since(started)

  # Step 3: fit the ensemble models and write evaluations.
  started <- Sys.time()
  ensemble <- step_ensemble_modeling(models, run_cfg, species_seed)
  timings$ensemble_modeling <- seconds_since(started)

  write_evaluation_outputs(models, ensemble, species_name)

  # Step 4: project individual models on current conditions.
  started <- Sys.time()
  current_projection <- project_models(
    models, current_environment, "current", run_cfg, species_seed
  )
  timings$current_projection <- seconds_since(started)

  # Step 5: forecast the current ensemble.
  started <- Sys.time()
  forecast_ensemble(
    ensemble, current_projection, "CurrentEM", run_cfg, species_seed
  )
  timings$current_ensemble <- seconds_since(started)

  # Step 6: project individual and ensemble models for every future scenario.
  future <- run_future_scenarios(
    models, ensemble, future_scenarios, terrain, soil, run_cfg, species_seed
  )
  future_timings <- future$timings
  timings$future_projection <- future$seconds

  write.table(
    as.data.frame(timings),
    file = paste0("time_", species_name, ".txt"),
    sep = "\t",
    row.names = FALSE
  )
  write.table(
    future_timings,
    file = paste0("time_future_", species_name, ".txt"),
    sep = "\t",
    row.names = FALSE
  )

  list(
    index = entry$index,
    species = species_name,
    occurrences = nrow(entry$rows),
    seed = species_seed,
    timings = timings
  )
}

if (!dir.exists(input_source)) {
  abort("Input directory does not exist: ", input_source)
}
dir.create(scratch_root, recursive = TRUE, showWarnings = FALSE)
dir.create(output_root, recursive = TRUE, showWarnings = FALSE)
remove_owned_tree(scratch_run, scratch_root)
dir.create(scratch_run, recursive = TRUE)
if (isTRUE(cfg$runtime$clean_output)) {
  remove_owned_tree(final_output, output_root)
}

cat("Staging input with", io_workers, "worker(s)...\n")
input_stage <- copy_tree(input_source, staged_input, io_workers)
cat(
  "Input staged:", input_stage$files, "files,", input_stage$bytes,
  "bytes in", input_stage$seconds, "seconds\n"
)

dir.create(work_output, recursive = TRUE, showWarnings = FALSE)
occurrences_file <- file.path(staged_input, "full_1km_EUNIS.csv")
occurrences <- read.csv(occurrences_file, check.names = FALSE)
required_columns <- c("sp_name", "x", "y", "pseudo-absences")
if (!all(required_columns %in% names(occurrences))) {
  abort("Occurrence CSV must contain: ", paste(required_columns, collapse = ", "))
}
if (any(is.na(occurrences[["pseudo-absences"]])) || any(occurrences[["pseudo-absences"]] != 1)) {
  abort("This POC expects presence-only rows with pseudo-absences equal to 1")
}
species_names <- sort(unique(occurrences$sp_name))
if (any(species_indices > length(species_names))) {
  abort("Species index exceeds available species count: ", length(species_names))
}
entries <- lapply(species_indices, function(index) {
  raw_name <- species_names[[index]]
  list(
    index = index,
    species_name = sub(" ", ".", raw_name, fixed = TRUE),
    rows = occurrences[occurrences$sp_name == raw_name, required_columns, drop = FALSE]
  )
})
rm(occurrences)
gc(verbose = FALSE)

run_cfg <- list(
  seed = as.integer(cfg$runtime$seed),
  model_workers = model_workers,
  ensemble_workers = min(model_workers, 2L),
  science = cfg$science
)
analysis_started <- Sys.time()
if (state$species_backend == "direct") {
  results <- lapply(entries, run_species, run_cfg, staged_input, work_output)
} else {
  snowfall::sfInit(parallel = TRUE, cpus = snowfall_workers)
  results <- tryCatch(
    {
      snowfall::sfLibrary("biomod2", character.only = TRUE)
      snowfall::sfLibrary("terra", character.only = TRUE)
      snowfall::sfLibrary("gbm", character.only = TRUE)
      snowfall::sfLibrary("mda", character.only = TRUE)
      snowfall::sfLibrary("randomForest", character.only = TRUE)
      snowfall::sfExport(
        "run_species", "load_environment", "list_future_scenarios", "list_tif_files",
        "build_seeded_random_cv", "step_formatting", "step_cross_validation",
        "step_modeling", "step_ensemble_modeling", "write_evaluation_outputs",
        "project_models", "forecast_ensemble", "run_future_scenarios",
        "seconds_since", "abort", "run_cfg", "staged_input", "work_output"
      )
      snowfall::sfLapply(
        entries,
        function(entry) run_species(entry, run_cfg, staged_input, work_output)
      )
    },
    finally = snowfall::sfStop(nostop = FALSE)
  )
}
analysis_seconds <- seconds_since(analysis_started)

dput(resolved, file.path(work_output, "resolved-config.R"))
cat("Publishing output with", io_workers, "worker(s)...\n")
output_publish <- copy_tree(work_output, final_output, io_workers)

write.csv(
  data.frame(
    resolved_variant = label,
    species_backend = state$species_backend,
    species_count = length(results),
    input_files = input_stage$files,
    input_bytes = input_stage$bytes,
    input_stage_secs = input_stage$seconds,
    analysis_secs = analysis_seconds,
    output_files = output_publish$files,
    output_bytes = output_publish$bytes,
    output_publish_secs = output_publish$seconds
  ),
  file.path(final_output, "poc_run_timing.csv"),
  row.names = FALSE
)

completed_at <- format(Sys.time(), "%Y-%m-%d %H:%M:%S%z")
for (result in results) {
  marker <- file.path(final_output, result$species, "_SUCCESS")
  writeLines(
    c(
      paste("species", result$species),
      paste("species_index", result$index),
      paste("resolved_variant", label),
      paste("model_workers", model_workers),
      paste("io_workers", io_workers),
      paste("species_backend", state$species_backend),
      paste("seed", result$seed),
      paste("completed_at", completed_at)
    ),
    marker
  )
}

cat(
  "POC completed:", label,
  "| analysis seconds =", analysis_seconds,
  "| output =", final_output, "\n"
)
if (isTRUE(cfg$runtime$clean_scratch_on_success)) {
  remove_owned_tree(scratch_run, scratch_root)
}

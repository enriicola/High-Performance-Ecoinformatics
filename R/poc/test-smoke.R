#!/usr/bin/env Rscript

# Run inside the project container. This synthetic integration test checks that
# changing I/O and BIOMOD2 worker profiles does not change scientific outputs.
suppressPackageStartupMessages(library(terra))

script_args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", script_args, value = TRUE)
script_path <- sub("^--file=", "", script_arg[[1]])
repo_root <- normalizePath(file.path(dirname(script_path), "../.."))
main_script <- file.path(repo_root, "R/poc/main.R")
smoke_root <- tempfile("r-poc-smoke-")
success <- FALSE

cleanup <- function() {
  if (success) {
    unlink(smoke_root, recursive = TRUE)
  } else {
    cat("Smoke-test files preserved at", smoke_root, "\n")
  }
}
on.exit(cleanup(), add = TRUE)

dir.create(file.path(smoke_root, "input/climate_vars/baseline"), recursive = TRUE)
dir.create(file.path(smoke_root, "input/climate_vars/future"), recursive = TRUE)
dir.create(file.path(smoke_root, "input/TRI_vars"), recursive = TRUE)
dir.create(file.path(smoke_root, "input/soil_vars"), recursive = TRUE)

set.seed(42)
template <- rast(
  nrows = 20, ncols = 20,
  xmin = 0, xmax = 20, ymin = 0, ymax = 20,
  crs = "EPSG:4326"
)
raster_paths <- c(
  "input/climate_vars/baseline/PC1.tif",
  "input/climate_vars/baseline/PC2.tif",
  "input/TRI_vars/TRI.tif",
  "input/soil_vars/PC1_Edaphic.tif",
  "input/soil_vars/PC2_Edaphic.tif"
)
for (index in seq_along(raster_paths)) {
  raster <- setValues(template, runif(ncell(template)) + index)
  writeRaster(raster, file.path(smoke_root, raster_paths[[index]]), overwrite = TRUE)
}

coordinates <- xyFromCell(template, sample(seq_len(ncell(template)), 40))
write.csv(
  data.frame(
    id = seq_len(nrow(coordinates)),
    sp_name = "Achillea atrata",
    x = coordinates[, 1],
    y = coordinates[, 2],
    check.names = FALSE,
    "pseudo-absences" = 1
  ),
  file.path(smoke_root, "input/full_1km_EUNIS.csv"),
  row.names = FALSE,
  quote = TRUE
)

config <- list(
  variant = "sequential_io_sequential_models",
  paths = list(
    input_dir = file.path(smoke_root, "input"),
    output_dir = file.path(smoke_root, "output"),
    scratch_dir = file.path(smoke_root, "scratch")
  ),
  runtime = list(
    model_workers = 2L,
    io_workers = 2L,
    snowfall_workers = 2L,
    seed = 42L,
    clean_output = TRUE,
    clean_scratch_on_success = TRUE
  ),
  species_indices = 1L,
  science = list(
    raster_names = c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil"),
    models = "GLM",
    pa_nb_rep = 1L,
    pa_nb_absences = 100L,
    pa_strategy = "random",
    filter_raster = FALSE,
    model_options_strategy = "bigboss",
    cv_strategy = "random",
    cv_nb_rep = 2L,
    cv_perc = 0.7,
    model_metric_eval = c("TSS", "AUCroc", "KAPPA"),
    scale_models = FALSE,
    cv_do_full_models = FALSE,
    ensemble_algorithms = "EMmean",
    ensemble_metric_select = "AUCroc",
    ensemble_metric_select_thresh = 0,
    ensemble_metric_eval = c("TSS", "AUCroc", "KAPPA"),
    projection_build_clamping_mask = TRUE,
    projection_keep_in_memory = FALSE,
    projection_do_stack = FALSE,
    future_limit = 0L
  )
)
config_path <- file.path(smoke_root, "config.R")
dput(config, config_path)

run_profile <- function(variant, run_id) {
  log_path <- file.path(smoke_root, paste0(run_id, ".log"))
  status <- system2(
    "Rscript",
    c(
      shQuote(main_script),
      paste0("--config=", shQuote(config_path)),
      paste0("--variant=", variant),
      paste0("--run-id=", run_id)
    ),
    stdout = log_path,
    stderr = log_path,
    env = "SLURM_CPUS_PER_TASK=2"
  )
  if (status != 0L) {
    cat(readLines(log_path), sep = "\n")
    stop("Smoke profile failed: ", variant, call. = FALSE)
  }
  file.path(smoke_root, "output", variant, run_id)
}

sequential_a <- run_profile("sequential_io_sequential_models", "sequential-a")
sequential_b <- run_profile("sequential_io_sequential_models", "sequential-b")
model_parallel <- run_profile("sequential_io_parallel_models", "model-parallel")
parallel <- run_profile("parallel_io_parallel_models", "parallel")

relative_paths <- function(root, paths) {
  substring(paths, nchar(root) + 2L)
}

compare_outputs <- function(left, right) {
  left_tifs <- sort(list.files(left, pattern = "\\.tif$", recursive = TRUE, full.names = TRUE))
  right_tifs <- sort(list.files(right, pattern = "\\.tif$", recursive = TRUE, full.names = TRUE))
  relative <- relative_paths(left, left_tifs)
  stopifnot(identical(relative, relative_paths(right, right_tifs)))

  for (path in relative) {
    left_raster <- rast(file.path(left, path))
    right_raster <- rast(file.path(right, path))
    stopifnot(compareGeom(left_raster, right_raster, stopOnError = FALSE))
    left_values <- values(left_raster, mat = FALSE)
    right_values <- values(right_raster, mat = FALSE)
    stopifnot(
      identical(is.na(left_values), is.na(right_values)),
      identical(left_values, right_values)
    )
  }

  for (path in c(
    "CV_Achillea.atrata.csv",
    "Eval_Achillea.atrata.txt",
    "Eval_EM_Achillea.atrata.txt"
  )) {
    stopifnot(identical(readLines(file.path(left, path)), readLines(file.path(right, path))))
  }
  stopifnot(
    file.exists(file.path(left, "Achillea.atrata/_SUCCESS")),
    file.exists(file.path(right, "Achillea.atrata/_SUCCESS"))
  )
}

compare_outputs(sequential_a, sequential_b)
compare_outputs(sequential_a, model_parallel)
compare_outputs(sequential_a, parallel)
success <- TRUE
cat("POC synthetic smoke test passed: repeated and parallel outputs match exactly\n")

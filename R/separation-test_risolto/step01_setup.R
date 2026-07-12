step01_setup <- function(ctx) {
  options(echo = TRUE)
  options(warn = 1)

  library(biomod2)
  library(terra)
  library(gbm)
  library(mda)
  library(randomForest)

  ctx$root <- normalizePath(".")
  ctx$in_dir <- file.path(ctx$root, "data/input")

  output_dir_override <- Sys.getenv("OUTPUT_DIR", "")
  ctx$out_dir <- if (nzchar(output_dir_override)) {
    normalizePath(output_dir_override, mustWork = FALSE)
  } else {
    file.path(ctx$root, "data/output")
  }
  dir.create(ctx$out_dir, showWarnings = FALSE, recursive = TRUE)

  ctx$input_csv <- Sys.getenv("INPUT_CSV", "full_1km_EUNIS.csv")
  ctx$pa_nb_rep <- env_int("PA_NB_REP", 10L)
  ctx$pa_nb_absences <- env_int("PA_NB_ABSENCES", 10000L)
  ctx$cv_nb_rep <- env_int("CV_NB_REP", 5L)

  future_limit_raw <- Sys.getenv("FUTURE_LIMIT", "")
  ctx$future_limit <- if (nzchar(future_limit_raw)) as.integer(future_limit_raw) else NA_integer_

  ctx$species_index <- as.integer(Sys.getenv("SPECIES_INDEX", Sys.getenv("SLURM_ARRAY_TASK_ID", "1")))
  ctx$final_sleep_seconds <- env_num("FINAL_SLEEP_SECONDS", 10)

  cat(
    "DEBUG: input_csv =", ctx$input_csv,
    "| PA.nb.rep =", ctx$pa_nb_rep,
    "| PA.nb.absences =", ctx$pa_nb_absences,
    "| CV.nb.rep =", ctx$cv_nb_rep,
    "| species_index =", ctx$species_index,
    "| out_dir =", ctx$out_dir, "\n"
  )

  invisible(ctx)
}

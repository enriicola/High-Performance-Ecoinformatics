args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
script_path <- if (length(file_arg) > 0) {
  sub("^--file=", "", file_arg[1])
} else {
  file.path(getwd(), "main.R")
}
script_dir <- dirname(normalizePath(script_path))

step_files <- c(
  "helpers.R",
  "step01_setup.R",
  "step02_load_occurrences.R",
  "step03_load_calibration_env.R",
  "step04_load_projection_env.R",
  "step05_load_future_list.R",
  "step06_prepare_species.R",
  "step07_format_data.R",
  "step08_model_options.R",
  "step09_modeling.R",
  "step10_ensemble_modeling.R",
  "step11_write_evaluations.R",
  "step12_current_projection.R",
  "step13_current_ensemble_projection.R",
  "step14_future_projection.R",
  "step15_write_timing.R"
)

for (step_file in step_files) {
  source(file.path(script_dir, step_file))
}

ctx <- new.env(parent = emptyenv())
ctx$script_dir <- script_dir

step01_setup(ctx)
step02_load_occurrences(ctx)
step03_load_calibration_env(ctx)
step04_load_projection_env(ctx)
step05_load_future_list(ctx)
step06_prepare_species(ctx)
step07_format_data(ctx)
step08_model_options(ctx)
step09_modeling(ctx)
step10_ensemble_modeling(ctx)
step11_write_evaluations(ctx)
step12_current_projection(ctx)
step13_current_ensemble_projection(ctx)
step14_future_projection(ctx)
step15_write_timing(ctx)

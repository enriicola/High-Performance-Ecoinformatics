# Step 2: individual model calibration.

step_modeling <- function(formatted, calibration_lines, entry, run_cfg, species_seed) {
  BIOMOD_Modeling(
    formatted,
    modeling.id = paste0("poc_", entry$index),
    models = run_cfg$science$models,
    CV.strategy = "user.defined",
    CV.user.table = calibration_lines,
    CV.do.full.models = FALSE,
    OPT.strategy = run_cfg$science$model_options_strategy,
    metric.eval = run_cfg$science$model_metric_eval,
    scale.models = run_cfg$science$scale_models,
    nb.cpu = run_cfg$model_workers,
    seed.val = species_seed,
    do.progress = TRUE
  )
}

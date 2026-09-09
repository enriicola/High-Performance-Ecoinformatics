# Step 5: ensemble forecasting on current conditions.

forecast_ensemble <- function(ensemble, projection, projection_name, run_cfg, species_seed) {
  doParallel::registerDoParallel(cores = run_cfg$ensemble_workers)
  BIOMOD_EnsembleForecasting(
    bm.em = ensemble,
    bm.proj = projection,
    proj.name = projection_name,
    models.chosen = "all",
    metric.binary = "all",
    metric.filter = "all",
    nb.cpu = run_cfg$ensemble_workers,
    seed.val = species_seed
  )
}

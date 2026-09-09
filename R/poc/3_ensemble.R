# Step 3: ensemble model calibration and evaluation output.

step_ensemble_modeling <- function(models, run_cfg, species_seed) {
  doParallel::registerDoParallel(cores = run_cfg$ensemble_workers)
  BIOMOD_EnsembleModeling(
    bm.mod = models,
    models.chosen = "all",
    em.by = "all",
    em.algo = run_cfg$science$ensemble_algorithms,
    metric.select = run_cfg$science$ensemble_metric_select,
    metric.select.thresh = run_cfg$science$ensemble_metric_select_thresh,
    metric.eval = run_cfg$science$ensemble_metric_eval,
    nb.cpu = run_cfg$ensemble_workers,
    seed.val = species_seed
  )
}

write_evaluation_outputs <- function(models, ensemble, species_name) {
  write.table(
    get_evaluations(models),
    file = paste0("Eval_", species_name, ".txt"),
    sep = "\t"
  )
  write.table(
    get_evaluations(ensemble),
    file = paste0("Eval_EM_", species_name, ".txt"),
    sep = "\t"
  )
}

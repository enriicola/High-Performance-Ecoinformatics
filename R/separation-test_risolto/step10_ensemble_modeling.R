step10_ensemble_modeling <- function(ctx) {
  start.time <- Sys.time()

  ctx$myBiomodEM <- BIOMOD_EnsembleModeling(
    bm.mod = ctx$myBiomodModelOut,
    models.chosen = "all",
    em.by = "all",
    em.algo = c("EMmean", "EMcv"),
    metric.select = "AUCroc",
    metric.select.thresh = 0.6,
    metric.eval = c("TSS", "AUCroc", "KAPPA"),
    nb.cpu = 1
  )

  ctx$time.modeling_EM <- Sys.time() - start.time
  ctx$myBiomodModelEval <- get_evaluations(ctx$myBiomodModelOut)
  ctx$myBiomodModelEval_ensamble <- get_evaluations(ctx$myBiomodEM)

  invisible(ctx)
}

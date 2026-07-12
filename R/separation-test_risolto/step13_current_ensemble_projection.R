step13_current_ensemble_projection <- function(ctx) {
  start.time <- Sys.time()

  ctx$myBiomodEMProj <- BIOMOD_EnsembleForecasting(
    bm.em = ctx$myBiomodEM,
    bm.proj = ctx$myBiomodProj,
    proj.name = "CurrentEM",
    models.chosen = "all",
    metric.binary = "all",
    metric.filter = "all",
    nb.cpu = 1
  )

  ctx$time.cur_proj_EM <- Sys.time() - start.time

  invisible(ctx)
}

step09_modeling <- function(ctx) {
  ctx$myBiomodModelOut <- BIOMOD_Modeling(
    ctx$myBiomodData,
    models = ctx$selModels,
    CV.strategy = "random",
    CV.nb.rep = ctx$cv_nb_rep,
    CV.perc = 0.7,
    OPT.strategy = "bigboss",
    metric.eval = c("TSS", "AUCroc", "KAPPA", "POD", "FAR"),
    scale.models = FALSE,
    CV.do.full.models = FALSE,
    nb.cpu = ctx$n_cpu,
    do.progress = T
  )

  ctx$time.modeling <- Sys.time() - ctx$modeling_start_time

  invisible(ctx)
}

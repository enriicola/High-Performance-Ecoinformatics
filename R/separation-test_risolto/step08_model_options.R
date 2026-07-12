step08_model_options <- function(ctx) {
  ctx$modeling_start_time <- Sys.time()

  ctx$opt.b <- bm_ModelingOptions(
    data.type = "binary",
    models = ctx$selModels,
    strategy = "bigboss",
    bm.format = ctx$myBiomodData
  )

  invisible(ctx)
}

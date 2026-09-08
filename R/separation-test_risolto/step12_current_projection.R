step12_current_projection <- function(ctx) {
  start.time <- Sys.time()

  ctx$myBiomodProj <- BIOMOD_Projection(
    bm.mod = ctx$myBiomodModelOut,
    proj.name = "current",
    new.env = ctx$cur_proj,
    models.chosen = "all",
    build.clamping.mask = T,
    keep.in.memory = FALSE,
    do.stack = FALSE,
    nb.cpu = ctx$n_cpu
  )

  ctx$time.cur_proj <- Sys.time() - start.time

  invisible(ctx)
}

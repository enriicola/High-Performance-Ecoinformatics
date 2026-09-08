step14_future_projection <- function(ctx) {
  ctx$nf <- length(ctx$lf)
  start.time <- Sys.time()

  if (ctx$nf > 0) {
    for (k in seq_len(ctx$nf)) {
      name <- ctx$lf[k]
      cat("\n\nDEBUG: Processing future scenario", k, "of", ctx$nf, ":", name, "\n")

      fut_files <- dir(ctx$lf[k], full.names = T)
      fut1 <- rast(fut_files)
      cat("DEBUG: Raster loaded, ncell =", ncell(fut1), ", hasValues =", hasValues(fut1), "\n")

      fut <- fut1
      fut_proj <- c(fut[[1]], fut[[2]], ctx$tri_proj, ctx$soil_proj[[1]], ctx$soil_proj[[2]])
      names(fut_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

      nm1 <- strsplit(name, "/")[[1]]
      nm <- paste0(nm1[length(nm1) - 1], "_", nm1[length(nm1)])
      nm2 <- paste0("futureEM_", nm1[length(nm1) - 1], "_", nm1[length(nm1)])

      myBiomodProj_fut <- BIOMOD_Projection(
        bm.mod = ctx$myBiomodModelOut,
        proj.name = nm,
        new.env = fut_proj,
        models.chosen = "all",
        build.clamping.mask = T,
        keep.in.memory = FALSE,
        do.stack = FALSE,
        nb.cpu = ctx$n_cpu
      )

      myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
        bm.em = ctx$myBiomodEM,
        bm.proj = myBiomodProj_fut,
        proj.name = nm2,
        models.chosen = "all",
        metric.binary = "all",
        metric.filter = "all",
        nb.cpu = 1
      )
    }
  }

  setTxtProgressBar(ctx$pb, ctx$i)
  Sys.sleep(ctx$final_sleep_seconds)
  ctx$time.fut_proj <- Sys.time() - start.time

  invisible(ctx)
}

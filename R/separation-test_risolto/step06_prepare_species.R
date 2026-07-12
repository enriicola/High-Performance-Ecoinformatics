step06_prepare_species <- function(ctx) {
  k <- ctx$species_index
  ctx$i <- k
  ctx$spocc1 <- subset(ctx$spocc, ctx$spocc[, 1] == ctx$sp.names[ctx$i])

  cat("DEBUG: array task", k, "-> species =", ctx$sp.names[ctx$i], "| occurrences =", nrow(ctx$spocc1), "\n")

  ctx$n_cpu <- if (nrow(ctx$spocc1) >= 50000) 4L else 1L
  cat("DEBUG: n_cpu =", ctx$n_cpu, "(threshold 50k)\n")

  ctx$species_dir <- file.path(ctx$out_dir, ctx$sp.names[ctx$i])
  unlink(ctx$species_dir, recursive = TRUE)

  invisible(ctx)
}

step05_load_future_list <- function(ctx) {
  lf <- list.dirs(file.path(ctx$in_dir, "climate_vars/future"), full.names = T, recursive = T)[-1]
  lf <- lf[sapply(lf, function(d) length(list.files(d, pattern = "\\.tif$")) > 0)]

  if (!is.na(ctx$future_limit)) {
    lf <- head(lf, ctx$future_limit)
  }

  ctx$lf <- lf
  cat("DEBUG: testing with", length(ctx$lf), "future scenarios\n")

  setwd(ctx$out_dir)
  ctx$pb <- txtProgressBar(min = 0, max = ctx$num_sp, style = 3, width = 50, char = "=")
  ctx$selModels <- c("GLM", "GBM", "ANN", "FDA", "MAXNET")

  invisible(ctx)
}

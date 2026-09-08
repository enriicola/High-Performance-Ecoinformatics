step02_load_occurrences <- function(ctx) {
  spocc <- read.csv(file.path(ctx$in_dir, ctx$input_csv), head = TRUE)
  spocc <- spocc[, -1]
  spocc$sp_name <- sub(" ", ".", spocc$sp_name)

  ctx$spocc <- spocc
  ctx$sp.names <- levels(factor(spocc[, 1]))
  ctx$num_sp <- length(ctx$sp.names)

  cat("DEBUG: num_sp =", ctx$num_sp, "| total rows =", nrow(ctx$spocc), "\n")

  invisible(ctx)
}

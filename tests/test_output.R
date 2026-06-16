# Validate biomod2 run output: every species dir under <out_dir> must contain the
# components a complete run produces, and every ensemble .tif must be a readable,
# non-empty raster (catches the dead-worker bug that wrote non-raster files).
#
# Structural + content check, param-independent: it does NOT compare PA/RUN counts,
# model leaf names, timestamps or metric names. Future scenarios are derived from
# the input future tree.
#
# Run (inside the container):
#   Rscript tests/test_output.R [out_dir] [future_dir]
#   defaults: data/output  data/input/climate_vars/future

library(testthat)
library(terra)

args <- commandArgs(trailingOnly = TRUE)
out_dir <- ifelse(length(args) >= 1, args[1], "data/output")
fut_dir <- ifelse(length(args) >= 2, args[2], "data/input/climate_vars/future")

# future scenarios = "<gcm>_<ssp>" from leaf dirs (.../future/<gcm>/<ssp>) holding tif
leaf <- list.dirs(fut_dir, full.names = TRUE, recursive = TRUE)[-1]
leaf <- leaf[sapply(leaf, function(d) length(list.files(d, pattern = "\\.tif$")) > 0)]
scenarios <- vapply(leaf, function(p) {
  parts <- strsplit(p, "/")[[1]]
  paste0(parts[length(parts) - 1], "_", parts[length(parts)])
}, character(1))
cat("scenarios (", length(scenarios), "): ", paste(scenarios, collapse = ", "), "\n", sep = "")

# helper: at least one path matches the glob
has <- function(glob) length(Sys.glob(glob)) > 0

# helper: file is a readable, non-empty raster
expect_valid_raster <- function(path) {
  expect_true(file.exists(path), info = paste("missing:", path))
  r <- tryCatch(terra::rast(path), error = function(e) NULL)
  expect_false(is.null(r), info = paste("not a readable raster:", path))
  if (!is.null(r)) {
    expect_gt(terra::ncell(r), 0)
    expect_true(terra::hasValues(r), info = paste("raster has no values:", path))
  }
}

species_dirs <- list.dirs(out_dir, full.names = TRUE, recursive = FALSE)
species_dirs <- species_dirs[basename(species_dirs) != "Eval"]
stopifnot(length(species_dirs) > 0)

for (sp_dir in species_dirs) {
  sp <- basename(sp_dir)

  test_that(paste(sp, "- model + ensemble objects present"), {
    expect_true(has(file.path(sp_dir, paste0(sp, ".*.models.out"))))
    expect_true(has(file.path(sp_dir, paste0(sp, ".*.ensemble.models.out"))))
    expect_true(has(file.path(sp_dir, "models", "*", "*")))
  })

  test_that(paste(sp, "- current projection valid"), {
    expect_valid_raster(file.path(sp_dir, "proj_current", paste0("proj_current_", sp, ".tif")))
    expect_valid_raster(file.path(
      sp_dir, "proj_currentEM",
      paste0("proj_currentEM_", sp, "_ensemble.tif")
    ))
  })

  for (sc in scenarios) {
    test_that(paste(sp, "- future", sc, "projection valid"), {
      expect_valid_raster(file.path(
        sp_dir, paste0("proj_", sc),
        paste0("proj_", sc, "_", sp, ".tif")
      ))
      expect_valid_raster(file.path(
        sp_dir, paste0("proj_futureEM_", sc),
        paste0("proj_futureEM_", sc, "_", sp, "_ensemble.tif")
      ))
    })
  }
}

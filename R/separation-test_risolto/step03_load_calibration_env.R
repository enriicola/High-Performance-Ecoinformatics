step03_load_calibration_env <- function(ctx) {
  cat("DEBUG: loading calibration rasters...\n")

  ctx$clim_cal <- rast(dir(file.path(ctx$in_dir, "climate_vars/baseline"), full.names = T))
  ctx$tri_cal <- rast(dir(file.path(ctx$in_dir, "TRI_vars"), full.names = T))
  ctx$soil_cal <- rast(dir(file.path(ctx$in_dir, "soil_vars"), full.names = T))
  ctx$cur_cal <- c(ctx$clim_cal, ctx$tri_cal, ctx$soil_cal)
  names(ctx$cur_cal) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

  cat("DEBUG: raster dim =", dim(ctx$cur_cal)[1], "x", dim(ctx$cur_cal)[2], "| ncell =", ncell(ctx$cur_cal), "\n")

  invisible(ctx)
}

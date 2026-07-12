step04_load_projection_env <- function(ctx) {
  ctx$clim_proj <- rast(dir(file.path(ctx$in_dir, "climate_vars/baseline"), full.names = T))
  ctx$tri_proj <- rast(dir(file.path(ctx$in_dir, "TRI_vars"), full.names = T))
  ctx$soil_proj <- rast(dir(file.path(ctx$in_dir, "soil_vars"), full.names = T))
  ctx$cur_proj <- c(ctx$clim_proj, ctx$tri_proj, ctx$soil_proj)
  names(ctx$cur_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

  invisible(ctx)
}

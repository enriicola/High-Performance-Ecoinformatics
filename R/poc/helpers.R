# Shared filesystem, environment and timing helpers.

is_within <- function(path, root) {
  path <- normalizePath(path, mustWork = FALSE)
  root <- normalizePath(root, mustWork = FALSE)
  startsWith(path, paste0(root, .Platform$file.sep))
}

remove_owned_tree <- function(path, root) {
  if (!is_within(path, root)) {
    abort("Refusing to remove path outside owned root: ", path)
  }
  if (file.exists(path) || dir.exists(path)) {
    unlink(path, recursive = TRUE)
  }
}

copy_tree <- function(source, destination, workers) {
  if (!dir.exists(source)) {
    abort("Source directory does not exist: ", source)
  }
  started <- Sys.time()
  source <- normalizePath(source)
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)

  directories <- list.dirs(source, recursive = TRUE, full.names = TRUE)
  relative_directories <- substring(directories, nchar(source) + 2L)
  for (relative in relative_directories[nzchar(relative_directories)]) {
    dir.create(file.path(destination, relative), recursive = TRUE, showWarnings = FALSE)
  }

  files <- list.files(
    source,
    recursive = TRUE,
    full.names = TRUE,
    all.files = TRUE,
    no.. = TRUE,
    include.dirs = FALSE
  )
  if (length(files) == 0L) {
    return(list(files = 0L, bytes = 0, seconds = 0))
  }

  relative_files <- substring(files, nchar(source) + 2L)
  destinations <- file.path(destination, relative_files)
  invisible(lapply(unique(dirname(destinations)), dir.create, recursive = TRUE, showWarnings = FALSE))
  copy_one <- function(index) {
    file.copy(
      files[[index]], destinations[[index]],
      overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE
    )
  }
  indices <- seq_along(files)
  copied <- if (workers == 1L) {
    vapply(indices, copy_one, logical(1))
  } else {
    unlist(parallel::mclapply(indices, copy_one, mc.cores = workers), use.names = FALSE)
  }
  if (!all(copied)) {
    failed <- relative_files[!copied]
    abort("Failed to copy: ", paste(failed, collapse = ", "))
  }

  list(
    files = length(files),
    bytes = sum(file.info(files)$size, na.rm = TRUE),
    seconds = as.numeric(difftime(Sys.time(), started, units = "secs"))
  )
}

list_tif_files <- function(path) {
  sort(list.files(path, pattern = "\\.tif$", full.names = TRUE, ignore.case = TRUE))
}

load_environment <- function(input_dir, raster_names) {
  climate_files <- list_tif_files(file.path(input_dir, "climate_vars/baseline"))
  terrain_files <- list_tif_files(file.path(input_dir, "TRI_vars"))
  soil_files <- list_tif_files(file.path(input_dir, "soil_vars"))
  if (length(climate_files) != 2L || length(terrain_files) != 1L || length(soil_files) != 2L) {
    abort("Expected 2 climate, 1 terrain and 2 soil rasters")
  }
  climate <- terra::rast(climate_files)
  terrain <- terra::rast(terrain_files)
  soil <- terra::rast(soil_files)
  environment <- c(climate, terrain, soil)
  if (terra::nlyr(environment) != length(raster_names)) {
    abort(
      "Expected ", length(raster_names), " environmental layers, found ",
      terra::nlyr(environment)
    )
  }
  names(environment) <- raster_names
  environment
}

list_future_scenarios <- function(input_dir, future_limit) {
  future_root <- file.path(input_dir, "climate_vars/future")
  if (!dir.exists(future_root)) {
    abort("Future scenario directory does not exist: ", future_root)
  }
  directories <- list.dirs(future_root, recursive = TRUE, full.names = TRUE)[-1]
  directories <- directories[vapply(
    directories,
    function(path) length(list_tif_files(path)) > 0L,
    logical(1)
  )]
  directories <- sort(directories)
  if (!is.null(future_limit)) {
    directories <- head(directories, as.integer(future_limit))
  }
  directories
}

seconds_since <- function(started) {
  as.numeric(difftime(Sys.time(), started, units = "secs"))
}

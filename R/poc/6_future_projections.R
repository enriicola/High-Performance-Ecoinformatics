# Step 6: individual and ensemble projections for future scenarios.

step_future_projections <- function(
  models, ensemble, future_scenarios, terrain, soil, run_cfg, species_seed
) {
  future_timings <- data.frame(
    scenario = character(),
    projection_secs = numeric(),
    ensemble_secs = numeric(),
    total_secs = numeric()
  )
  future_started <- Sys.time()
  for (scenario_path in future_scenarios) {
    scenario_started <- Sys.time()
    parts <- strsplit(scenario_path, .Platform$file.sep, fixed = TRUE)[[1]]
    scenario <- paste(tail(parts, 2L), collapse = "_")
    future_climate <- terra::rast(list_tif_files(scenario_path))
    if (terra::nlyr(future_climate) != 2L) {
      abort("Expected two climate layers for scenario: ", scenario_path)
    }
    future_environment <- c(future_climate[[1:2]], terrain, soil)
    names(future_environment) <- run_cfg$science$raster_names

    projection_started <- Sys.time()
    future_projection <- step_projection(
      models, future_environment, scenario, run_cfg, species_seed
    )
    projection_seconds <- seconds_since(projection_started)

    ensemble_started <- Sys.time()
    step_ensemble_forecast(
      ensemble, future_projection, paste0("futureEM_", scenario), run_cfg, species_seed
    )
    ensemble_seconds <- seconds_since(ensemble_started)

    future_timings <- rbind(
      future_timings,
      data.frame(
        scenario = scenario,
        projection_secs = projection_seconds,
        ensemble_secs = ensemble_seconds,
        total_secs = seconds_since(scenario_started)
      )
    )
    rm(future_climate, future_environment, future_projection)
    gc(verbose = FALSE)
  }
  list(timings = future_timings, seconds = seconds_since(future_started))
}

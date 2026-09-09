# Step 1: BIOMOD2 formatting, pseudo-absence handling and deterministic CV.

build_seeded_random_cv <- function(formatted, nb_rep, perc, do_full_models, seed) {
  if (!methods::is(formatted, "BIOMOD.formated.data.PA")) {
    abort("The deterministic POC split expects presence/pseudo-absence data")
  }
  if (nb_rep < 2L && !do_full_models) {
    abort("BIOMOD2 4.3-4-5 requires at least two user-defined CV columns")
  }
  if (perc <= 0 || perc > 1) {
    abort("cv_perc must be greater than 0 and at most 1")
  }
  if (any(vapply(formatted@data.env.var, is.factor, logical(1)))) {
    abort("The POC deterministic split has not been validated for factor predictors")
  }

  species <- formatted@data.species
  pa_table <- formatted@PA.table
  take <- function(values, size) {
    if (size == 0L) integer() else if (length(values) == 1L) values else sample(values, size)
  }
  columns <- list()
  set.seed(seed)
  for (pa_index in seq_len(ncol(pa_table))) {
    included <- which(pa_table[, pa_index] %in% TRUE)
    presences <- included[which(species[included] > 0)]
    absences <- setdiff(included, presences)
    for (run_index in seq_len(nb_rep)) {
      calibration <- rep(NA, length(species))
      calibration[included] <- FALSE
      calibration[take(presences, round(length(presences) * perc))] <- TRUE
      calibration[take(absences, round(length(absences) * perc))] <- TRUE
      columns[[paste0("_PA", pa_index, "_RUN", run_index)]] <- calibration
    }
  }

  if (do_full_models) {
    columns[["_allData_allRun"]] <- rep(TRUE, length(species))
    for (pa_index in seq_len(ncol(pa_table))) {
      full_pa <- rep(NA, length(species))
      full_pa[pa_table[, pa_index] %in% TRUE] <- TRUE
      columns[[paste0("_PA", pa_index, "_allRun")]] <- full_pa
    }
  }
  do.call(cbind, columns)
}

step_formatting <- function(entry, run_cfg, current_environment, species_name, species_seed) {
  BIOMOD_FormatingData(
    resp.var = rep(1, nrow(entry$rows)),
    expl.var = current_environment,
    resp.xy = entry$rows[, c("x", "y"), drop = FALSE],
    resp.name = species_name,
    PA.nb.rep = run_cfg$science$pa_nb_rep,
    PA.nb.absences = run_cfg$science$pa_nb_absences,
    PA.strategy = run_cfg$science$pa_strategy,
    na.rm = TRUE,
    filter.raster = run_cfg$science$filter_raster,
    seed.val = species_seed
  )
}

step_cross_validation <- function(formatted, run_cfg, species_name, species_seed) {
  if (run_cfg$science$cv_strategy != "random") {
    abort("This POC currently supports only deterministic random cross-validation")
  }
  calibration_lines <- build_seeded_random_cv(
    formatted = formatted,
    nb_rep = run_cfg$science$cv_nb_rep,
    perc = run_cfg$science$cv_perc,
    do_full_models = run_cfg$science$cv_do_full_models,
    seed = species_seed
  )
  write.csv(
    calibration_lines,
    file = paste0("CV_", species_name, ".csv"),
    row.names = FALSE
  )
  calibration_lines
}

# Proof-of-concept values. Keep them fixed across execution profiles.
list(
  variant = "sequential_io_sequential_models",
  paths = list(
    input_dir = "data/input",
    output_dir = "data/output/poc",
    scratch_dir = Sys.getenv("TMPDIR", "/tmp/tesi-poc")
  ),
  runtime = list(
    model_workers = 4L,
    io_workers = 4L,
    snowfall_workers = 2L,
    seed = 42L,
    clean_output = TRUE,
    clean_scratch_on_success = TRUE
  ),
  species_indices = 1L,
  science = list(
    raster_names = c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil"),
    models = c("GLM", "GBM", "ANN", "FDA", "MAXNET"),
    pa_nb_rep = 5L,
    pa_nb_absences = 10000L,
    pa_strategy = "random",
    filter_raster = FALSE,
    model_options_strategy = "bigboss",
    cv_strategy = "random",
    cv_nb_rep = 5L,
    cv_perc = 0.7,
    model_metric_eval = c("TSS", "AUCroc", "KAPPA", "POD", "FAR"),
    scale_models = FALSE,
    cv_do_full_models = FALSE,
    ensemble_algorithms = c("EMmean", "EMcv"),
    ensemble_metric_select = "AUCroc",
    ensemble_metric_select_thresh = 0.6,
    ensemble_metric_eval = c("TSS", "AUCroc", "KAPPA"),
    projection_build_clamping_mask = TRUE,
    projection_keep_in_memory = FALSE,
    projection_do_stack = FALSE,
    future_limit = NULL
  )
)

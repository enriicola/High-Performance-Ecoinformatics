options(echo = TRUE) # stampa ogni statement prima di eseguirlo
options(warn = 1) # stampa i warning quando accadono (non in blocco a fine run)

env_true <- function(name, default) {
  tolower(Sys.getenv(name, default)) %in% c("1", "true", "yes", "y")
}

# Runtime configuration -----------------------------------------------------
n_cpu <- suppressWarnings(as.integer(Sys.getenv(
  "BIOMOD_NCPU",
  Sys.getenv("SLURM_CPUS_PER_TASK", "5")
)))
if (is.na(n_cpu) || n_cpu < 1L) {
  stop("BIOMOD_NCPU must be a positive integer")
}
allocated_cpus <- suppressWarnings(as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "")))
if (!is.na(allocated_cpus) && n_cpu > allocated_cpus) {
  stop("BIOMOD_NCPU cannot exceed SLURM_CPUS_PER_TASK (", allocated_cpus, ")")
}
ensemble_n_cpu <- min(n_cpu, 2L)
projection_keep_in_memory <- env_true("PROJ_KEEP_IN_MEMORY", "false")
projection_do_stack <- env_true("PROJ_DO_STACK", "true")

# Input/output paths --------------------------------------------------------
root <- normalizePath(".")
in_dir <- file.path(root, "data/input")
out_dir <- Sys.getenv("BIOMOD_OUTPUT_DIR", file.path(root, "data/output"))
occurrences_file <- file.path(in_dir, "full_1km_EUNIS.csv")
climate_baseline_dir <- file.path(in_dir, "climate_vars/baseline")
tri_dir <- file.path(in_dir, "TRI_vars")
soil_dir <- file.path(in_dir, "soil_vars")
future_dir <- file.path(in_dir, "climate_vars/future")
raster_names <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

# Algorithm configuration ---------------------------------------------------
model_data_type <- "binary"
selModels <- c("GLM", "GBM", "ANN", "FDA", "MAXNET")
pa_nb_rep <- 5L
pa_nb_absences <- 10000L
pa_strategy <- "random"
filter_raster <- FALSE

model_options_strategy <- "bigboss"
cv_strategy <- "random"
cv_nb_rep <- 5L
cv_perc <- 0.7
model_metric_eval <- c("TSS", "AUCroc", "KAPPA", "POD", "FAR")
scale_models <- FALSE
cv_do_full_models <- FALSE
do_progress <- TRUE

ensemble_algorithms <- c("EMmean", "EMcv")
ensemble_metric_select <- "AUCroc"
ensemble_metric_select_thresh <- 0.6
ensemble_metric_eval <- c("TSS", "AUCroc", "KAPPA")

projection_build_clamping_mask <- TRUE

cat(
  "DEBUG: BIOMOD workers =", n_cpu,
  "| ensemble workers =", ensemble_n_cpu,
  "| Slurm CPUs =", ifelse(is.na(allocated_cpus), "unknown", allocated_cpus), "\n",
  "DEBUG: projection keep.in.memory =", projection_keep_in_memory,
  "| do.stack =", projection_do_stack, "\n"
)

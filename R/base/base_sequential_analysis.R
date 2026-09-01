# old script name was: ensamble_modelling_no_parallel
# Adapted to run inside the Singularity container on Leonardo (repo layout + mini dataset).
# Changes vs the collaborator's Windows version (see git message):
#   - paths E:/... and Enrico/... -> ./data/input/... (repo layout)
#   - removed makeCluster/registerDoParallel (hangs inside Singularity)
#   - removed dplyr dependency (base R sub() for the species name)
#   - fixed syntax error `OPT.strategy = 'bigboss',,`
#   - future-name parsing made path-depth independent (length-based indexing)
# Kept her two key fixes from the original algorithm:
#   - BIOMOD_EnsembleForecasting(bm.proj = ...) reuses the computed projection
#     -> no internal mclapply re-projection -> avoids the step-6 OOM
#   - CV.do.full.models = FALSE -> no allRun/allData model bloat
source("R/base/config.R")

library(biomod2)
library(terra)
library(gbm)
library(mda)
library(randomForest)

# biomod2 registers its own doParallel backend from nb.cpu; an external cluster
# is unnecessary and previously hung inside the Singularity container.

dir.create(out_dir, showWarnings = FALSE)

####################################
# loading species occurrences data
####################################
spocc <- read.csv(occurrences_file, head = TRUE)
spocc <- spocc[, -1] # drop id -> cols: sp_name, x, y, pseudo-absences
spocc$sp_name <- sub(" ", ".", spocc$sp_name)
sp.names <- levels(factor(spocc[, 1]))
num_sp <- length(sp.names)
cat("DEBUG: num_sp =", num_sp, "| total rows =", nrow(spocc), "\n")

#####################################
# CALIBRATION environmental data
#####################################
cat("DEBUG: loading calibration rasters...\n")
clim_cal <- rast(dir(climate_baseline_dir, full.names = T))
tri_cal <- rast(dir(tri_dir, full.names = T))
soil_cal <- rast(dir(soil_dir, full.names = T))
cur_cal <- c(clim_cal, tri_cal, soil_cal)
names(cur_cal) <- raster_names
cat("DEBUG: raster dim =", dim(cur_cal)[1], "x", dim(cur_cal)[2], "| ncell =", ncell(cur_cal), "\n")

#####################################
# PROJECTION environmental data
#####################################
# Projection and calibration use the same baseline rasters. Reuse their handles
# instead of loading a second copy into the R process.
cur_proj <- cur_cal
tri_proj <- tri_cal
soil_proj <- soil_cal

#####################################
# loading FUTURE list (leaf dirs containing tif)
#####################################
lf <- list.dirs(future_dir, full.names = T, recursive = T)[-1]
lf <- lf[sapply(lf, function(d) length(list.files(d, pattern = "\\.tif$")) > 0)]
cat("DEBUG: testing with", length(lf), "future scenarios\n")

# outputs (biomod2 writes species folders into the working dir)
setwd(out_dir)

# One Slurm array task processes exactly one species.
task_id <- suppressWarnings(as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "1")))
if (is.na(task_id) || task_id < 1L || task_id > num_sp) {
  stop("SLURM_ARRAY_TASK_ID must be between 1 and ", num_sp)
}
species_name <- sp.names[[task_id]]
spocc1 <- spocc[spocc[, 1] == species_name, , drop = FALSE]
cat(
  "DEBUG: array task", task_id,
  "-> species =", species_name,
  "| occurrences =", nrow(spocc1), "\n"
)

# The full occurrence table is no longer needed by this isolated species task.
rm(spocc)
gc(verbose = FALSE)

# Per-species cleanup is safe when different array tasks process distinct species.
species_dir <- file.path(out_dir, species_name)
unlink(species_dir, recursive = TRUE)

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

start.time <- Sys.time()
myRespName <- species_name
myRespXY <- spocc1[, 2:3] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

cat("DEBUG: starting BIOMOD_FormatingData at", format(Sys.time(), "%H:%M:%S"), "\n")
flush.console()

# 1. Formatting Data
# resp è la distribuzione della specie
# expl sono le variabili che vanno a spiegare la distribuzione della specie (spiegano la resp) (caldo, freddo, neve, etc)

myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp, # response variable
  expl.var = cur_cal, # explenatory variable
  resp.xy = myRespXY, # longitude and latitude of species occurrences
  resp.name = myRespName,
  PA.nb.rep = pa_nb_rep,
  PA.nb.absences = pa_nb_absences,
  PA.strategy = pa_strategy,
  na.rm = TRUE,
  filter.raster = filter_raster
)

cat("DEBUG: BIOMOD_FormatingData done at", format(Sys.time(), "%H:%M:%S"), "\n")
end.time <- Sys.time()
time.formating <- end.time - start.time

start.time <- Sys.time()
# 2. Defining Models Options (bigboss preset)
opt.b <- bm_ModelingOptions(
  data.type = model_data_type,
  models = selModels,
  strategy = model_options_strategy,
  bm.format = myBiomodData
)

# 3. Computing the models
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = selModels,
  CV.strategy = cv_strategy,
  CV.nb.rep = cv_nb_rep,
  CV.perc = cv_perc,
  OPT.strategy = model_options_strategy,
  metric.eval = model_metric_eval,
  scale.models = scale_models,
  CV.do.full.models = cv_do_full_models,
  nb.cpu = n_cpu,
  do.progress = do_progress
)
end.time <- Sys.time()
time.modeling <- end.time - start.time

# Modeling leaves its global foreach backend registered. Select the intended
# backend explicitly before building the two ensemble algorithms.
doParallel::registerDoParallel(cores = ensemble_n_cpu)

start.time <- Sys.time()
# 4. Model ensemble models
myBiomodEM <- BIOMOD_EnsembleModeling(
  bm.mod = myBiomodModelOut,
  models.chosen = "all",
  em.by = "all",
  em.algo = ensemble_algorithms,
  metric.select = ensemble_metric_select,
  metric.select.thresh = ensemble_metric_select_thresh,
  metric.eval = ensemble_metric_eval,
  nb.cpu = ensemble_n_cpu
)
end.time <- Sys.time()
time.modeling_EM <- end.time - start.time

### Models evaluations
myBiomodModelEval <- get_evaluations(myBiomodModelOut)
myBiomodModelEval_ensamble <- get_evaluations(myBiomodEM)

# TODO change output to csv
nome <- paste0("Eval_", species_name, ".txt", sep = "")
write.table(myBiomodModelEval, file = nome, sep = "\t")

nome1 <- paste0("Eval_EM_", species_name, ".txt", sep = "")
write.table(myBiomodModelEval_ensamble, file = nome1, sep = "\t")

###########################################################################
######################      PROJECTION ON ALPS        #####################
###########################################################################

###########################################################################
###########################           CURRENT   ###########################
###########################################################################

# 5. Individual models projections on current environmental conditions
start.time <- Sys.time()
myBiomodProj <- BIOMOD_Projection(
  bm.mod = myBiomodModelOut,
  proj.name = "current",
  new.env = cur_proj,
  models.chosen = "all",
  build.clamping.mask = projection_build_clamping_mask,
  keep.in.memory = projection_keep_in_memory,
  do.stack = projection_do_stack,
  nb.cpu = n_cpu
)
end.time <- Sys.time()
time.cur_proj <- end.time - start.time

# BIOMOD_Projection leaves its global foreach backend registered. Ensemble
# forecasting receives bm.proj, so select its two-worker backend explicitly.
doParallel::registerDoParallel(cores = ensemble_n_cpu)

# 6. Project ensemble models (reuse bm.proj to avoid internal re-projection)
start.time <- Sys.time()
myBiomodEMProj <- BIOMOD_EnsembleForecasting(
  # """nuovo raster con altri dati ambientali""" (proiezione della proiezione)
  bm.em = myBiomodEM,
  bm.proj = myBiomodProj, # reuse computed projection; biomod2 wants XOR(bm.proj, new.env)
  proj.name = "CurrentEM",
  models.chosen = "all",
  metric.binary = "all",
  metric.filter = "all",
  nb.cpu = ensemble_n_cpu
)
end.time <- Sys.time()
time.cur_proj_EM <- end.time - start.time

###########################################################################
#######################################   FUTURE     ######################
###########################################################################

## Number of future projections
# 5 global circulation models (GCM), variazione di gas serra, metano, etc, nell'atmosfera nel futuro, e all'interno di ognuno ci sono due scenari (ottimista SSP370 e pessimista SSP585), TODO check acronyms
# 10 future projections (5 GCM x 2 SSP) -> 10 proiezioni future per ogni specie
# calibrazione solo su current (presente), per avere una base di partenza, e la proiezione serve due volte
# proiezione sul futuro viene fatta partendo dai dati del primo (e unico) biomod modelling e sulle var ambientali future, per vedere come cambiano le predizioni

nf <- length(lf)
future_timings <- data.frame(
  scenario = character(),
  projection_secs = numeric(),
  ensemble_secs = numeric(),
  total_secs = numeric()
)

start.time <- Sys.time()
for (k in 1:nf) {
  scenario_start <- Sys.time()
  name <- lf[k]
  cat("\n\nDEBUG: Processing future scenario", k, "of", nf, ":", name, "\n")

  fut_files <- dir(lf[k], full.names = T)
  fut1 <- rast(fut_files)
  cat("DEBUG: Raster loaded, ncell =", ncell(fut1), ", hasValues =", hasValues(fut1), "\n")

  fut_proj <- c(fut1[[1]], fut1[[2]], tri_proj, soil_proj[[1]], soil_proj[[2]])
  names(fut_proj) <- raster_names

  # path-depth independent: <gcm>/<ssp> are the last two path components
  nm1 <- strsplit(name, "/")[[1]]
  nm <- paste0(nm1[length(nm1) - 1], "_", nm1[length(nm1)])
  nm2 <- paste0("futureEM_", nm1[length(nm1) - 1], "_", nm1[length(nm1)])

  # 5. Individual models projections on future environmental conditions
  projection_start <- Sys.time()
  myBiomodProj_fut <- BIOMOD_Projection(
    bm.mod = myBiomodModelOut,
    proj.name = nm,
    new.env = fut_proj,
    models.chosen = "all",
    build.clamping.mask = projection_build_clamping_mask,
    keep.in.memory = projection_keep_in_memory,
    do.stack = projection_do_stack,
    nb.cpu = n_cpu
  )
  projection_end <- Sys.time()

  doParallel::registerDoParallel(cores = ensemble_n_cpu)
  ensemble_start <- Sys.time()
  myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
    bm.em = myBiomodEM,
    bm.proj = myBiomodProj_fut, # reuse computed projection; biomod2 wants XOR(bm.proj, new.env)
    proj.name = nm2,
    models.chosen = "all",
    metric.binary = "all",
    metric.filter = "all",
    nb.cpu = ensemble_n_cpu
  )
  ensemble_end <- Sys.time()

  future_timings <- rbind(
    future_timings,
    data.frame(
      scenario = nm,
      projection_secs = as.numeric(projection_end - projection_start, units = "secs"),
      ensemble_secs = as.numeric(ensemble_end - ensemble_start, units = "secs"),
      total_secs = as.numeric(ensemble_end - scenario_start, units = "secs")
    )
  )

  rm(fut1, fut_proj, myBiomodProj_fut, myBiomodEMProj_fut)
  gc(verbose = FALSE)
}
end.time <- Sys.time()
time.fut_proj <- end.time - start.time

# force seconds: write.table strips difftime units and R auto-picks a unit per value,
# so columns aren't comparable. as.numeric(., units="secs") makes them uniform.
time <- data.frame(
  formating = as.numeric(time.formating, units = "secs"),
  modeling = as.numeric(time.modeling, units = "secs"),
  modeling_EM = as.numeric(time.modeling_EM, units = "secs"),
  cur_projection = as.numeric(time.cur_proj, units = "secs"),
  cur_projection_EM = as.numeric(time.cur_proj_EM, units = "secs"),
  fut_projection = as.numeric(time.fut_proj, units = "secs")
)
write.table(time, paste0("time_", species_name, ".txt"), sep = "\t")
write.table(
  future_timings,
  paste0("time_future_", species_name, ".txt"),
  sep = "\t",
  row.names = FALSE
)
writeLines(
  c(
    paste("species", species_name),
    paste("task_id", task_id),
    paste("biomod_ncpu", n_cpu),
    paste("ensemble_ncpu", ensemble_n_cpu),
    paste("completed_at", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
  ),
  file.path(species_dir, "_SUCCESS")
)

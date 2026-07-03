# old script name was: ensamble_modelling_no_parallel
# Adapted to run inside the Singularity container on Leonardo (repo layout + mini dataset).
# Changes vs the collaborator's Windows version (see git message):
#   - paths E:/... and Enrico/... -> ./data/input/... (repo layout)
#   - removed makeCluster/registerDoParallel (hangs inside Singularity)
#   - removed dplyr dependency (base R sub() for the species name)
#   - fixed syntax error `OPT.strategy = 'bigboss',,`
#   - future-name parsing made path-depth independent (length-based indexing)
# Kept her two key fixes vs our new.ensamble_modelling.R:
#   - BIOMOD_EnsembleForecasting(bm.proj = ...) reuses the computed projection
#     -> no internal mclapply re-projection -> avoids the step-6 OOM
#   - CV.do.full.models = FALSE -> no allRun/allData model bloat
env_true <- function(name, default = "false") {
  tolower(Sys.getenv(name, default)) %in% c("1", "true", "yes", "y")
}

debug_echo <- env_true("R_DEBUG_ECHO", "false")
options(echo = debug_echo) # ~ set -x : stampa ogni statement prima di eseguirlo
options(warn = 1) # stampa i warning quando accadono (non in blocco a fine run)

library(biomod2)
library(terra)
library(gbm)
library(mda)
library(randomForest)

# NOTE: makeCluster/registerDoParallel removed - hangs inside Singularity container.
# TODO: check if without makeCluster nb.cpu=x is ignored and if actually runs in parallel
# cl <- makeCluster(10)
# registerDoParallel(cl)

root <- normalizePath(".")
in_dir <- file.path(root, "data/input")
out_dir <- file.path(root, "data/output")
dir.create(out_dir, showWarnings = FALSE)

terra_tmp <- file.path(out_dir, ".terra_tmp")
dir.create(terra_tmp, showWarnings = FALSE, recursive = TRUE)
terra_memfrac <- as.numeric(Sys.getenv("TERRA_MEMFRAC", "0.7"))
terraOptions(memfrac = terra_memfrac, tempdir = terra_tmp)
cat("DEBUG: R_DEBUG_ECHO =", debug_echo, "| TERRA_MEMFRAC =", terra_memfrac, "\n")

####################################
# loading species occurrences data
####################################
spocc <- read.csv(file.path(in_dir, "full_1km_EUNIS.csv"), head = TRUE)
spocc <- spocc[, -1] # drop id -> cols: sp_name, x, y, pseudo-absences
spocc$sp_name <- sub(" ", ".", spocc$sp_name)
sp.names <- levels(factor(spocc[, 1]))
num_sp <- length(sp.names)
cat("DEBUG: num_sp =", num_sp, "| total rows =", nrow(spocc), "\n")

#####################################
# CALIBRATION environmental data
#####################################
cat("DEBUG: loading calibration rasters...\n")
clim_cal <- rast(dir(file.path(in_dir, "climate_vars/baseline"), full.names = T))
tri_cal <- rast(dir(file.path(in_dir, "TRI_vars"), full.names = T))
soil_cal <- rast(dir(file.path(in_dir, "soil_vars"), full.names = T))
cur_cal <- c(clim_cal, tri_cal, soil_cal)
names(cur_cal) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")
cat("DEBUG: raster dim =", dim(cur_cal)[1], "x", dim(cur_cal)[2], "| ncell =", ncell(cur_cal), "\n")

#####################################
# PROJECTION environmental data
#####################################
# Reuse baseline rasters already loaded for calibration (avoid duplicate reads/copies)
cur_proj <- cur_cal
tri_proj <- tri_cal
soil_proj <- soil_cal

#####################################
# loading FUTURE list (leaf dirs containing tif)
#####################################
lf <- list.dirs(file.path(in_dir, "climate_vars/future"), full.names = T, recursive = T)[-1]
lf <- lf[sapply(lf, function(d) length(list.files(d, pattern = "\\.tif$")) > 0)]
cat("DEBUG: testing with", length(lf), "future scenarios\n")

# outputs (biomod2 writes species folders into the working dir)
setwd(out_dir)

pb <- txtProgressBar(min = 0, max = num_sp, style = 3, width = 50, char = "=")

selModels <- c("GLM", "GBM", "ANN", "FDA", "MAXNET")

# SLURM array task -> one species (array id = index into full sorted species list)
k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "1"))
i <- k
species_name <- sp.names[i]
spocc1 <- subset(spocc, spocc[, 1] == species_name)
cat("DEBUG: array task", k, "-> species =", species_name, "| occurrences =", nrow(spocc1), "\n")

# free global occurrence table ASAP after selecting the current species
rm(spocc)
gc(verbose = FALSE)

# TODO: study if quicker to run for loop inside r or submit slurm arrays of jobs
# TODO maybe do both
# TODO check if it's possible to run multicore with a sinle ram copy, instead of a copy for each core

# parallel fork count for Modeling + Projection only. EnsembleForecasting stays nb.cpu=1.
# Small datasets (<50k occ) trigger mclapply SIGPIPE race conditions at n_cpu>1 (job 47510573_2/_3).
# Use n_cpu=1 for small species to avoid the forking bug.
n_cpu <- if (nrow(spocc1) >= 50000) 4L else 1L
cat("DEBUG: n_cpu =", n_cpu, "(threshold 50k)\n")

# projection memory mode: keep OOM-safe defaults, but allow override for experiments
projection_keep_in_memory <- env_true("PROJ_KEEP_IN_MEMORY", "false")
projection_do_stack <- env_true("PROJ_DO_STACK", "false")
cat(
  "DEBUG: projection_keep_in_memory =", projection_keep_in_memory,
  "| projection_do_stack =", projection_do_stack, "\n"
)

species_dir <- file.path(out_dir, species_name)
force_clean <- env_true("FORCE_CLEAN", "false")
if (force_clean) {
  # per-species output wipe (array-safe: only this task's species dir, not sibling tasks')
  unlink(species_dir, recursive = TRUE)
  cat("DEBUG: FORCE_CLEAN=TRUE -> cleaned", species_dir, "\n")
}

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

start.time <- Sys.time()
myRespName <- species_name
myRespXY <- spocc1[, 2:3] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

cat("DEBUG: starting BIOMOD_FormatingData at", format(Sys.time(), "%H:%M:%S"), "\n")
flush.console()

# 1. Formatting Data (10 set of pseudo-absences, 10000 absences each, random strategy)
# resp è la distribuzione della specie
# expl sono le variabili che vanno a spiegare la distribuzione della specie (spiegano la resp) (caldo, freddo, neve, etc)

myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp, # response variable
  expl.var = cur_cal, # explenatory variable
  resp.xy = myRespXY, # longitude and latitude of species occurrences
  resp.name = myRespName,
  PA.nb.rep = 10, # production value, set of replicas
  PA.nb.absences = 10000, # production value (was toy 10); grows modeling only, projection unchanged
  PA.strategy = "random",
  na.rm = TRUE,
  filter.raster = F # se la response var deve essere filtrata (se troppi punti vanno nella stessa cella), se true si rischia di andare a sovrastimare (overfitting)
)

cat("DEBUG: BIOMOD_FormatingData done at", format(Sys.time(), "%H:%M:%S"), "\n")
end.time <- Sys.time()
time.formating <- end.time - start.time

start.time <- Sys.time()
# 2. Defining Models Options (bigboss preset)
opt.b <- bm_ModelingOptions(
  data.type = "binary",
  models = selModels,
  strategy = "bigboss", # statistic method, parametri definiti dal team di biomod2, strategia già definita, parametri ottimali, ps: non sono quelli di default, sono quelli ottimali
  bm.format = myBiomodData
)

# 3. Computing the models
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = selModels,
  CV.strategy = "random",
  CV.nb.rep = 5, # number of repetitions for cross validation, in order to validate the performance of the single model/algorithm
  CV.perc = 0.7, # valuta sul 70% dei dati e anche per calibrarsi (training) e testa querllo che ha imparato sul 30% dei dati, e va a fare un cross validation per vedere quanto è stato performante il modello rispetto al testing
  OPT.strategy = "bigboss",
  metric.eval = c("TSS", "AUCroc", "KAPPA", "POD", "FAR"),
  scale.models = FALSE, # default, chiede se tutte le proiezioni debbano essere scalate in binomiale (TODO check if we can delete this param, as it is default false)
  CV.do.full.models = FALSE, # default a false, chiede se venga fatta calibrazione e valutazione anche sulle pseudo-assenze
  nb.cpu = n_cpu,
  do.progress = T
)
end.time <- Sys.time()
time.modeling <- end.time - start.time

start.time <- Sys.time()
# 4. Model ensemble models
myBiomodEM <- BIOMOD_EnsembleModeling(
  bm.mod = myBiomodModelOut,
  models.chosen = "all",
  em.by = "all",
  em.algo = c("EMmean", "EMcv"), # c(...) is for multiple options, chose these 2 algorithms because we do not need the median. it does the mean of all models and then does a standard deviation of them (covariance)
  metric.select = "AUCroc", # standard, most used, various articles say it's the best
  metric.select.thresh = 0.6, # threshold value for exclude the models that are not performing over a certain threshold, in this case 0.6
  metric.eval = c("TSS", "AUCroc", "KAPPA"), # 3 most used
  nb.cpu = 1 # TODO add cores
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
  build.clamping.mask = T, # opzione per avere un'idea delle località in cui la predizione è incerta, dove non è sicuro di quello che sta predicendo, predizione potrebbe essere incerta, perchè i dati ambientali potrebbero non essere così fedeli alle variabili attinenti alla presenza vera delal specie (un modo per capire l'incertezza della predizione per ogni cella (km quadrato))
  keep.in.memory = projection_keep_in_memory,
  do.stack = projection_do_stack,
  nb.cpu = 1 # parallel write race condition -> crash (job 48325677_3)
)
end.time <- Sys.time()
time.cur_proj <- end.time - start.time

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
  nb.cpu = 1 # TODO add cores
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
force_rebuild_future <- env_true("FORCE_REBUILD_FUTURE", "false")

start.time <- Sys.time()
for (k in 1:nf) {
  name <- lf[k]
  cat("\n\nDEBUG: Processing future scenario", k, "of", nf, ":", name, "\n")

  # path-depth independent: <gcm>/<ssp> are the last two path components
  nm1 <- strsplit(name, "/")[[1]]
  nm <- paste0(nm1[length(nm1) - 1], "_", nm1[length(nm1)])
  nm2 <- paste0("futureEM_", nm1[length(nm1) - 1], "_", nm1[length(nm1)])

  proj_dir <- file.path(species_dir, paste0("proj_", nm))
  em_proj_dir <- file.path(species_dir, paste0("proj_", nm2))
  if (!force_rebuild_future && dir.exists(proj_dir) && dir.exists(em_proj_dir)) {
    cat("DEBUG: skipping already completed scenario", nm, "\n")
    next
  }

  fut_files <- dir(lf[k], full.names = T)
  fut1 <- rast(fut_files)
  cat("DEBUG: Raster loaded, ncell =", ncell(fut1), ", hasValues =", hasValues(fut1), "\n")

  fut_proj <- c(fut1[[1]], fut1[[2]], tri_proj, soil_proj[[1]], soil_proj[[2]])
  names(fut_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

  # 5. Individual models projections on future environmental conditions
  myBiomodProj_fut <- BIOMOD_Projection(
    bm.mod = myBiomodModelOut,
    proj.name = nm,
    new.env = fut_proj,
    models.chosen = "all",
    build.clamping.mask = T,
    keep.in.memory = projection_keep_in_memory,
    do.stack = projection_do_stack,
    nb.cpu = 1 # parallel write race condition -> crash (job 48325677_3)
  )

  myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
    bm.em = myBiomodEM,
    bm.proj = myBiomodProj_fut, # reuse computed projection; biomod2 wants XOR(bm.proj, new.env)
    proj.name = nm2,
    models.chosen = "all",
    metric.binary = "all",
    metric.filter = "all",
    nb.cpu = 1
  )

  rm(fut1, fut_proj, myBiomodProj_fut, myBiomodEMProj_fut)
  gc(verbose = FALSE)
}
setTxtProgressBar(pb, i)
end.time <- Sys.time()
time.fut_proj <- end.time - start.time
close(pb)

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

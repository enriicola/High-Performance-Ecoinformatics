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
options(echo = TRUE) # ~ set -x : stampa ogni statement prima di eseguirlo
options(warn = 1) # stampa i warning quando accadono (non in blocco a fine run)

library(biomod2)
library(terra)
library(gbm)
library(mda)
library(randomForest)

# NOTE: makeCluster/registerDoParallel removed - hangs inside Singularity container.

root <- normalizePath(".")
in_dir <- file.path(root, "data/input")
out_dir <- file.path(root, "data/output")
dir.create(out_dir, showWarnings = FALSE)

####################################
# loading species occurrences data
####################################
spocc <- read.csv(file.path(in_dir, "agrostis_1km_EUNIS.csv"), head = TRUE)
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
clim_proj <- rast(dir(file.path(in_dir, "climate_vars/baseline"), full.names = T))
tri_proj <- rast(dir(file.path(in_dir, "TRI_vars"), full.names = T))
soil_proj <- rast(dir(file.path(in_dir, "soil_vars"), full.names = T))
cur_proj <- c(clim_proj, tri_proj, soil_proj)
names(cur_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

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

# parallel fork count for Modeling + Projection only. EnsembleForecasting stays nb.cpu=1:
# its bm.proj reuse already avoids the re-projection fork that caused the step-6 OOM.
# Cap modest: nb.cpu >= 16 historically OOM'd (big-parent forks). Raise only after a clean test.
n_cpu <- 4L

# DEBUG: use first species
i <- 1
spocc1 <- subset(spocc, spocc[, 1] == sp.names[i])
cat("DEBUG: species =", sp.names[i], "| occurrences =", nrow(spocc1), "\n")

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

start.time <- Sys.time()
myRespName <- paste(sp.names[i], sep = ".")
myRespXY <- spocc1[, 2:3] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

cat("DEBUG: starting BIOMOD_FormatingData at", format(Sys.time(), "%H:%M:%S"), "\n")
flush.console()

# 1. Formatting Data
myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp,
  expl.var = cur_cal,
  resp.xy = myRespXY,
  resp.name = myRespName,
  PA.nb.rep = 3,
  PA.nb.absences = 10000, # production value (was toy 10); grows modeling only, projection unchanged
  PA.strategy = "random",
  na.rm = TRUE,
  filter.raster = F
)

cat("DEBUG: BIOMOD_FormatingData done at", format(Sys.time(), "%H:%M:%S"), "\n")
end.time <- Sys.time()
time.formating <- end.time - start.time

start.time <- Sys.time()
# 2. Defining Models Options (bigboss preset)
opt.b <- bm_ModelingOptions(
  data.type = "binary",
  models = selModels,
  strategy = "bigboss",
  bm.format = myBiomodData
)

# 3. Computing the models
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = selModels,
  CV.strategy = "random",
  CV.nb.rep = 2, # DEBUG: reduced from 5
  CV.perc = 0.7,
  OPT.strategy = "bigboss",
  metric.eval = c("TSS", "AUCroc", "KAPPA", "POD", "FAR"),
  scale.models = FALSE,
  CV.do.full.models = FALSE,
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
  em.algo = c("EMmean", "EMcv"),
  metric.select = c("AUCroc"),
  metric.select.thresh = c(0.6),
  metric.eval = c("TSS", "AUCroc", "KAPPA"),
  nb.cpu = 1
)
end.time <- Sys.time()
time.modeling_EM <- end.time - start.time

### Models evaluations
myBiomodModelEval <- get_evaluations(myBiomodModelOut)
myBiomodModelEval_ensamble <- get_evaluations(myBiomodEM)

nome <- paste0("Eval_", sp.names[i], ".txt", sep = "")
write.table(myBiomodModelEval, file = nome, sep = "\t")

nome1 <- paste0("Eval_EM_", sp.names[i], ".txt", sep = "")
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
  build.clamping.mask = T,
  nb.cpu = n_cpu
)
end.time <- Sys.time()
time.cur_proj <- end.time - start.time

# 6. Project ensemble models (reuse bm.proj to avoid internal re-projection)
start.time <- Sys.time()
myBiomodEMProj <- BIOMOD_EnsembleForecasting(
  bm.em = myBiomodEM,
  bm.proj = myBiomodProj, # reuse computed projection; biomod2 wants XOR(bm.proj, new.env)
  proj.name = "CurrentEM",
  models.chosen = "all",
  metric.binary = "all",
  metric.filter = "all",
  nb.cpu = 1
)
end.time <- Sys.time()
time.cur_proj_EM <- end.time - start.time

###########################################################################
#######################################   FUTURE     ######################
###########################################################################

## Number of future projections
nf <- length(lf)

start.time <- Sys.time()
for (k in 1:nf) {
  name <- lf[k]
  cat("\n\nDEBUG: Processing future scenario", k, "of", nf, ":", name, "\n")

  fut_files <- dir(lf[k], full.names = T)
  fut1 <- rast(fut_files)
  cat("DEBUG: Raster loaded, ncell =", ncell(fut1), ", hasValues =", hasValues(fut1), "\n")

  fut <- fut1
  fut_proj <- c(fut[[1]], fut[[2]], tri_proj, soil_proj[[1]], soil_proj[[2]])
  names(fut_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

  # path-depth independent: <gcm>/<ssp> are the last two path components
  nm1 <- strsplit(name, "/")[[1]]
  nm <- paste0(nm1[length(nm1) - 1], "_", nm1[length(nm1)])
  nm2 <- paste0("futureEM_", nm1[length(nm1) - 1], "_", nm1[length(nm1)])

  # 5. Individual models projections on future environmental conditions
  myBiomodProj_fut <- BIOMOD_Projection(
    bm.mod = myBiomodModelOut,
    proj.name = nm,
    new.env = fut_proj,
    models.chosen = "all",
    build.clamping.mask = T,
    nb.cpu = n_cpu
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
}
setTxtProgressBar(pb, i)
Sys.sleep(10)
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
write.table(time, paste0("time_", sp.names[i], ".txt"), sep = "\t")

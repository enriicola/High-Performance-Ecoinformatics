library(biomod2)
library(raster)
library(terra)
library(gbm)
library(mda)
library(Hmisc)
library(plyr)
library(doParallel)

# Parallelization inside functions
# cl <- makeCluster(10)
# registerDoParallel(cl)

####################################
# loading species occurrences data
####################################
TEST_N_ROWS <- 100
TEST_N_PSEUDO_ABSENCES <- 50
print(paste("n rows: ", TEST_N_ROWS))
print(paste("n pseudo-absences: ", TEST_N_PSEUDO_ABSENCES))

spocc <- read.table("data/input/data_62768_rows.csv", head = TRUE, sep = ",", nrows = TEST_N_ROWS)
sp.names <- levels(factor(spocc$sp_name)) # Use the second column (sp_name)
num_sp <- length(sp.names)

#####################################
# CALIBRATION environmental data
#####################################

#####################################
# loading CURRENT environmental data
#####################################

# Loading and naming rasters explicitly
clim_cal <- rast(dir("data/input/PCA/baseline", pattern = "\\.tif$", full.names = T))
names(clim_cal) <- c("PC1clim", "PC2clim")

tri_cal <- rast(dir("data/input/TRI", pattern = "\\.tif$", full.names = T))
names(tri_cal) <- "tri"

soil_cal <- rast(dir("data/input/PCA/Suolo", pattern = "\\.tif$", full.names = T))
names(soil_cal) <- c("PC1soil", "PC2soil")

# Merging into a single stack
cur_cal <- c(clim_cal, tri_cal, soil_cal)
cur_cal <- spatSample(cur_cal, size = ncell(cur_cal), as.raster = TRUE)

#####################################
# loading FUTURE list
#####################################

lf <- list.dirs("data/input/PCA/Futuro", full.names = T, recursive = T)[-1]
lf <- as.matrix(lf)
lf <- lf[nchar(lf[, 1]) >= 38, ]

pb <- txtProgressBar(
  min = 0,
  max = num_sp,
  style = 3,
  width = 50,
  char = "="
)

selModels <- c("GBM")

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

start.time <- Sys.time()
myRespName <- make.names(sp.names[1])
myRespXY <- spocc[1:TEST_N_ROWS, 3:4]
myResp <- rep(1, TEST_N_ROWS)

# 1. Formatting Data
print("Formatting Data...")

myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp,
  expl.var = cur_cal,
  resp.xy = myRespXY,
  resp.name = myRespName,
  PA.nb.rep = 1,
  PA.nb.absences = TEST_N_PSEUDO_ABSENCES,
  PA.strategy = "random",
  na.rm = TRUE,
  filter.raster = TRUE
)

# DIAGNOSTIC CHECK: Verify points were not dropped due to raster NA values
print("--- BIOMOD DATA SUMMARY ---")
summary(myBiomodData)
print("---------------------------")

end.time <- Sys.time()
time.formating <- end.time - start.time

start.time <- Sys.time()

# 2. Defining Models Options
opt.b <- bm_ModelingOptions(
  data.type = "binary",
  models = selModels,
  strategy = "bigboss",
  bm.format = myBiomodData
)

# 3. Computing the models
# FIX: Removed "POD" and "FAR" from metric.eval to prevent divide-by-zero crashes
myBiomodModelOut <- BIOMOD_Modeling(
  myBiomodData,
  models = selModels,
  CV.strategy = "random",
  CV.nb.rep = 1,
  CV.perc = 0.7,
  OPT.user = opt.b,
  metric.eval = c("TSS", "AUCroc", "KAPPA"),
  scale.models = FALSE,
  CV.do.full.models = FALSE,
  nb.cpu = 1,
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
  em.algo = c("EMmean"),
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

###########################################################################
######################      PROJECTION ON ALPS        #####################
###########################################################################

# 5. Individual models projections on current environmental conditions
start.time <- Sys.time()
myBiomodProj <- BIOMOD_Projection(
  bm.mod = myBiomodModelOut,
  proj.name = "current",
  new.env = cur_cal,
  models.chosen = "all",
  build.clamping.mask = T,
  nb.cpu = 1
)

end.time <- Sys.time()
time.cur_proj <- end.time - start.time

# 6. Project ensemble models
start.time <- Sys.time()
myBiomodEMProj <- BIOMOD_EnsembleForecasting(
  bm.em = myBiomodEM,
  proj.name = "CurrentEM",
  new.env = cur_cal,
  models.chosen = "all",
  metric.binary = "all",
  metric.filter = "all"
)

end.time <- Sys.time()
time.cur_proj_EM <- end.time - start.time

###########################################################################
#######################################   FUTURE     ######################
###########################################################################

nf <- 1

start.time <- Sys.time()
for (k in 1:nf) {
  name <- lf[k]

  fut1 <- rast(dir(lf[k], pattern = "\\.tif$", full.names = T))
  fut <- fut1
  fut_proj <- c(fut[[1]], fut[[2]], tri_cal, soil_cal[[1]], soil_cal[[2]])
  fut_proj <- rast(fut_proj)
  fut_proj <- spatSample(fut_proj, size = ncell(fut_proj), as.raster = TRUE)

  names(fut_proj) <- c("PC1clim", "PC2clim", "tri", "PC1soil", "PC2soil")
  fut_proj <- fut_proj[[names(cur_cal)]]

  folder_name <- basename(name)
  parent_folder <- basename(dirname(name))
  nm <- paste0(parent_folder, "_", folder_name)
  nm2 <- paste0("futureEM_", parent_folder, "_", folder_name)

  # 5. Individual models projections on future environmental conditions
  myBiomodProj_fut <- BIOMOD_Projection(
    bm.mod = myBiomodModelOut,
    proj.name = nm,
    new.env = fut_proj,
    models.chosen = "all",
    build.clamping.mask = T,
    nb.cpu = 1
  )

  myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
    bm.em = myBiomodEM,
    bm.proj = myBiomodProj_fut,
    proj.name = nm2,
    new.env = fut_proj,
    models.chosen = "all",
    metric.binary = "all",
    metric.filter = "all"
  )
}

setTxtProgressBar(pb, 1)
Sys.sleep(10)
end.time <- Sys.time()
time.fut_proj <- end.time - start.time

close(pb)

time <- data.frame(
  formating = time.formating, modeling = time.modeling, modeling_EM = time.modeling_EM, cur_projection = time.cur_proj,
  cur_projection_EM = time.cur_proj_EM, fut_projection = time.fut_proj
)

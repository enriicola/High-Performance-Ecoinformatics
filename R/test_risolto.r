# old script name was: ensamble_modelling_no_parallel
simpleError
library(biomod2)
# library(raster)
library(terra)
# library(rgdal)
library(gbm)
library(mda)
library(randomForest)
# library(Hmisc)
# library(plyr)
# library(maptools)
library(doParallel)
# library(profvis)
library(dplyr)

cl <- makeCluster(8)
registerDoParallel(cl)

dir.create("./data/output", showWarnings = FALSE)


####################################
# loading species occurrences data
####################################
spocc <- read.csv("Enrico/data_62768_rows.csv", head = TRUE)
spocc <- spocc[, -1]
spocc <- spocc %>%
  mutate(sp_name = sub(" ", ".", sp_name))
# DEBUG: keep full dataset, will truncate per-species later
sp.names <- levels(factor(spocc[, 1]))
num_sp <- length(sp.names)
cat("DEBUG: num_sp =", num_sp, "| total rows =", nrow(spocc), "\n")


#####################################
# CALIBRATION environmental data
#####################################

#####################################
# loading CURRENT environmental data
#####################################
cat("DEBUG: loading calibration rasters...\n")
clim_cal <- rast(dir("E:/Alpine grasslands/SDM_Vars/PCA/baseline", full.names = T))
tri_cal <- rast(dir("E:/Alpine grasslands/TRI", full.names = T))
soil_cal <- rast(dir("E:/Alpine grasslands/SDM_Vars/PCA/Suolo", full.names = T))
cur_cal <- c(clim_cal, tri_cal, soil_cal)
names(cur_cal) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")
cat("DEBUG: raster dim =", dim(cur_cal)[1], "x", dim(cur_cal)[2], "| ncell =", ncell(cur_cal), "\n")

#####################################
# PROJECTION environmental data
#####################################

#####################################
# loading CURRENT environmental data
#####################################
clim_proj <- rast(dir("E:/Alpine grasslands/SDM_Vars/PCA/baseline", full.names = T))
tri_proj <- rast(dir("E:/Alpine grasslands/TRI", full.names = T))
soil_proj <- rast(dir("E:/Alpine grasslands/SDM_Vars/PCA/Suolo", full.names = T))
cur_proj <- c(clim_proj, tri_proj, soil_proj)
names(cur_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

#####################################
# loading FUTURE list
#####################################

lf <- list.dirs("E:/Alpine grasslands/SDM_Vars/PCA/Future", full.names = T, recursive = T)[-1]
# Keep only directories that contain .tif files
lf <- lf[sapply(lf, function(d) length(list.files(d, pattern = "\\.tif$")) > 0)]
# DEBUG: limit future scenarios
cat("DEBUG: testing with", length(lf), "future scenarios\n")
#####################################
# Select bioclimatic variables
#####################################
# l<-c(4,10, 19)
# cur<-cur1[[l]]


pb <- txtProgressBar(
  min = 0, # Minimum value of the progress bar
  max = num_sp, # Maximum value of the progress bar
  style = 3, # Progress bar style (also available style = 1 and style = 2)
  width = 50, # Progress bar width. Defaults to getOption("width")
  char = "="
) # Character used to create the bar


selModels <- c("GLM", "GBM", "ANN", "FDA", "MAXNET")


# num_sp=98
# for(i in 39:43)  {      #i=1:num_sp	#i=1

# DEBUG: use first species
i <- 1
spocc1 <- subset(spocc, spocc[, 1] == sp.names[i])
# DEBUG: truncate to 1000 occurrences for testing
spocc1 <- spocc1[1:min(1000, nrow(spocc1)), ]
cat("DEBUG: species =", sp.names[i], "| occurrences =", nrow(spocc1), "\n")

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

###########################################################################
######################     ENSAMBLE       CURRENT     #####################
###########################################################################

start.time <- Sys.time()
myRespName <- paste(sp.names[i], sep = ".")
myRespXY <- spocc1[, 2:3] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

cat("DEBUG: starting BIOMOD_FormatingData at", format(Sys.time(), "%H:%M:%S"), "\n")
cat("DEBUG: resp points =", nrow(myRespXY), "| PA.nb.absences = 500 | PA.nb.rep = 2\n")
flush.console()

# 1. Formatting Data

myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp,
  expl.var = cur_cal,
  resp.xy = myRespXY,
  resp.name = myRespName,
  PA.nb.rep = 3,
  PA.nb.absences = 10,
  PA.strategy = "random",
  na.rm = TRUE,
  filter.raster = F
)

cat("DEBUG: BIOMOD_FormatingData done at", format(Sys.time(), "%H:%M:%S"), "\n")

end.time <- Sys.time()
time.formating <- end.time - start.time
cat("DEBUG: formatting took", round(time.formating, 2), "seconds\n")

start.time <- Sys.time()
# 2. Defining Models Options using default options.
# bigboss parameters
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
  OPT.strategy = "bigboss", ,
  metric.eval = c("TSS", "AUCroc", "KAPPA", "POD", "FAR"),
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

nome <- paste0("./data/output/Eval_", sp.names[i], ".txt", sep = "")
write.table(myBiomodModelEval, file = nome, sep = "\t")

nome1 <- paste0("./data/output/Eval_EM_", sp.names[i], ".txt", sep = "")
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
  nb.cpu = 1
)

end.time <- Sys.time()
time.cur_proj <- end.time - start.time

# 6. Project ensemble models

start.time <- Sys.time()

myBiomodEMProj <- BIOMOD_EnsembleForecasting(
  bm.em = myBiomodEM,
  proj.name = "CurrentEM",
  new.env = cur_proj,
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
  cat("DEBUG: Found", length(fut_files), "files:", paste(basename(fut_files), collapse = ", "), "\n")

  fut1 <- rast(fut_files)
  cat("DEBUG: Raster loaded, ncell =", ncell(fut1), ", hasValues =", hasValues(fut1), "\n")


  # names(fut1)<-lnames
  fut <- fut1
  fut_proj <- c(fut[[1]], fut[[2]], tri_proj, soil_proj[[1]], soil_proj[[2]])
  names(fut_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

  nm1 <- strsplit(name, "/")[[1]]
  nm <- paste0(nm1[5], "_", nm1[6])
  nm2 <- paste0("futureEM_", nm1[5], "_", nm1[6])

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
    metric.filter = "all",
    nb.cpu = 1
  )
}
setTxtProgressBar(pb, i) # Sets the progress bar to the current state
Sys.sleep(10)
end.time <- Sys.time()
time.fut_proj <- end.time - start.time
# }
close(pb) # Close the connection


time <- data.frame(
  formating = time.formating, modeling = time.modeling, modeling_EM = time.modeling_EM, cur_projection = time.cur_proj,
  cur_projection_EM = time.cur_proj_EM, fut_projection = time.fut_proj
)
write.table(time, paste0("./data/output/time_", sp.names[i], ".txt"), sep = "\t")

# save.image(file="SDM_praterie.RData")


# r <- rast("Omalotheca hoppeana/proj_currentEM/proj_currentEM_Omalotheca hoppeana_ensemble.tif")
# plot(r)

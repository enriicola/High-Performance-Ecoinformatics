library(biomod2)
library(raster)
library(terra)
library(gbm)
library(mda)
library(Hmisc)
library(plyr)
library(doParallel)
# library(profvis)

# Parallelization inside functions
# cl <- makeCluster(10)
# registerDoParallel(cl)


####################################
# loading species occurrences data
####################################
TEST_N_ROWS <- 500
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
clim_cal <- rast(dir("data/input/PCA/baseline", full.names = T))
names(clim_cal) <- c("PC1clim", "PC2clim")

tri_cal <- rast(dir("data/input/TRI", full.names = T))
names(tri_cal) <- "tri"

soil_cal <- rast(dir("data/input/PCA/Suolo", full.names = T))
names(soil_cal) <- c("PC1soil", "PC2soil")

# Merging into a single stack
cur_cal <- c(clim_cal, tri_cal, soil_cal)

#####################################
# loading FUTURE list
#####################################

lf <- list.dirs("data/input/PCA/Futuro", full.names = T, recursive = T)[-1]
lf <- as.matrix(lf)
lf <- lf[nchar(lf[, 1]) >= 38, ] # TODO refactor this line programmatically

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


selModels <- c("GBM")


# Take the third species in "spocc" and only the first 10 000 points of occurrence
# i=3
# spocc1<-subset(spocc, spocc[,1]==sp.names[i])
# spocc1 <- spocc1[1:500,]

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

###########################################################################
######################     ENSAMBLE       CURRENT     #####################
###########################################################################

start.time <- Sys.time()
myRespName <- make.names(sp.names[1]) # Make syntactically valid (no spaces)
myRespXY <- spocc[1:TEST_N_ROWS, 3:4] # coordinates of points (subsampled)
myResp <- rep(1, TEST_N_ROWS) # species occurences (subsampled)

# 1. Formatting Data
print("Formatting Data...")

myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp,
  expl.var = cur_cal,
  resp.xy = myRespXY,
  resp.name = myRespName,
  PA.nb.rep = 1,
  PA.nb.absences = 50,
  PA.strategy = "random",
  na.rm = TRUE,
  filter.raster = TRUE
)


end.time <- Sys.time()
time.formating <- end.time - start.time

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
  CV.nb.rep = 1,
  CV.perc = 0.7,
  OPT.user = opt.b,
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

# nome<-paste0("C:/Users/User/Desktop/SDM_Alps/Eval_", sp.names[i], ".txt", sep="")
# write.table(myBiomodModelEval , file=nome, sep="\t")

# nome1<-paste0("C:/Users/User/Desktop/SDM_Alps/Eval_EM_", sp.names[i], ".txt", sep="")
# write.table(myBiomodModelEval_ensamble , file=nome1, sep="\t")


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
  # nb.cpu = 1
)

end.time <- Sys.time()
time.cur_proj_EM <- end.time - start.time

###########################################################################
#######################################   FUTURE     ######################
###########################################################################

## Number of future projections (reduced for testing)
nf <- 1


start.time <- Sys.time()
for (k in 1:nf) {
  name <- lf[k]

  fut1 <- rast(dir(lf[k], full.names = T))


  # names(fut1)<-lnames
  fut <- fut1
  fut_proj <- c(fut[[1]], fut[[2]], tri_cal, soil_cal[[1]], soil_cal[[2]])
  fut_proj <- rast(fut_proj)
  names(fut_proj) <- c("PC1clim", "PC2clim", "tri", "PC1soil", "PC2soil")

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
    metric.filter = "all"
    # nb.cpu = 1
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

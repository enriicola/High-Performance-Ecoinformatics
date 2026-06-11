# ensamble_modelling_no_parallel

# debugging:
options(echo=TRUE)
options(warn=1) # print warnings as they occur
options(verbose=TRUE)
# trace(functionName)		       # trace specific function
# trace(BIOMOD_FormatingData)  # example
# untrace(functionName) 		   # stop tracing
# debug(functionName)      		 # enter debugger on each call
# browser()              			 # insert breakpoint in code
###

# Configuration
OUTPUT_DIR <- "./data/output"

# Force sequential processing - raster projections use too much RAM in parallel
SAFE_CPU <- 1
cat("DEBUG: Using", SAFE_CPU, "CPUs (forced sequential to avoid OOM)\n")

library(biomod2)
#library(raster)
library(terra)

# Limit terra memory usage - force temp files for large operations
terraOptions(memmax = 4)  # max 4GB in-memory, rest spills to disk
cat("DEBUG: terra memmax set to 4GB\n")
#library(rgdal)
library(gbm)
library(mda)
library(randomForest)
#library(Hmisc)
#library(plyr)
#library(maptools)
library(doParallel)
#library(profvis)

# Skip cluster for sequential mode
if (SAFE_CPU > 1) {
  cl <- makeCluster(SAFE_CPU)
  registerDoParallel(cl)
} else {
  registerDoSEQ()  # sequential backend
}

dir.create(OUTPUT_DIR, showWarnings=FALSE)


####################################
# loading species occurrences data
####################################
spocc <- read.csv("./data/input/full_1km_EUNIS.csv", head=TRUE)
# DEBUG: keep full dataset, will truncate per-species later
sp.names<-levels(factor(spocc[,2]))
num_sp<-length(sp.names)



#####################################
# CALIBRATION environmental data 
#####################################

#####################################
# loading CURRENT environmental data
#####################################
cat("DEBUG: loading calibration rasters...\n")
clim_cal=rast(dir("./data/input/climate_vars/baseline", full.names=T))
tri_cal=rast(dir("./data/input/TRI_vars", full.names=T))
soil_cal=rast(dir("./data/input/soil_vars", full.names=T))
cur_cal<-c(clim_cal,tri_cal,soil_cal)
names(cur_cal)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

#####################################
# PROJECTION environmental data 
#####################################

#####################################
# loading CURRENT environmental data
#####################################
clim_proj=rast(dir("./data/input/climate_vars/baseline", full.names=T))
tri_proj=rast(dir("./data/input/TRI_vars", full.names=T))
soil_proj=rast(dir("./data/input/soil_vars", full.names=T))
cur_proj<- c(clim_proj,tri_proj,soil_proj)
names(cur_proj)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

#####################################
# loading FUTURE list
#####################################

lf=list.dirs("./data/input/climate_vars/future", full.names=T, recursive = T)[-1]
# Keep only directories that contain .tif files
lf=lf[sapply(lf, function(d) length(list.files(d, pattern="\\.tif$")) > 0)]
#####################################
# Select bioclimatic variables
#####################################
#l<-c(4,10, 19)
#cur<-cur1[[l]]


pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = num_sp, # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 50,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar


selModels <- c("GLM", "GBM",  "ANN", "FDA", "MAXNET")


#num_sp=98
#for(i in 39:43)  {      #i=1:num_sp	#i=1

i=1
spocc1<-subset(spocc, spocc[,2]==sp.names[i])
# spocc1 <- spocc1[1:100000,]

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

###########################################################################
######################     ENSAMBLE       CURRENT     #####################
###########################################################################

start.time <- Sys.time()
myRespName <- paste (sp.names[i], sep = "")
myRespXY <- spocc1[,3:4] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

flush.console()

# 1. Formatting Data

myBiomodData <- BIOMOD_FormatingData(
						resp.var = myResp,
                                       expl.var = cur_cal,
                                       resp.xy = myRespXY,
                                       resp.name = myRespName,
                                       dir.name = OUTPUT_DIR,
                                       PA.nb.rep = 3,
                                       PA.nb.absences = 100,
                                       PA.strategy = 'random',
                          		   na.rm = TRUE,
						   filter.raster = F)


end.time <- Sys.time()
time.formating <- end.time - start.time

start.time <- Sys.time()
# 2. Defining Models Options using default options.
# bigboss parameters
opt.b <- bm_ModelingOptions(data.type = 'binary',
                            models = selModels,
                            strategy = 'bigboss',
				    bm.format = myBiomodData)

# 3. Computing the models
	
myBiomodModelOut <- BIOMOD_Modeling(
						myBiomodData,
						models = selModels,
						CV.strategy = 'random',
						CV.nb.rep = 3,
						CV.perc = 0.8,
						OPT.user = opt.b,
						metric.eval  = c('TSS', 'AUCroc', 'KAPPA', 'POD', 'FAR'),
						scale.models = FALSE,
						CV.do.full.models = FALSE,
						nb.cpu=SAFE_CPU,
						do.progress=T)
	
end.time <- Sys.time()
time.modeling <- end.time - start.time

start.time <- Sys.time()
# 4. Model ensemble models

myBiomodEM <- BIOMOD_EnsembleModeling(
						bm.mod = myBiomodModelOut,
                                    models.chosen = 'all',
                                    em.by = 'all',
                                    em.algo = c('EMmean', "EMcv"),
                                    metric.select = c('AUCroc'),
                                    metric.select.thresh = c(0.6),
                                    metric.eval = c('TSS', 'AUCroc', 'KAPPA'),
						nb.cpu = SAFE_CPU)

end.time <- Sys.time()
time.modeling_EM <- end.time - start.time


###Models evaluations

	myBiomodModelEval <- get_evaluations(myBiomodModelOut)
	myBiomodModelEval_ensamble <- get_evaluations(myBiomodEM)

	nome<-paste0(OUTPUT_DIR, "/Eval_", sp.names[i], ".txt", sep="")
	write.table(myBiomodModelEval , file=nome, sep="\t")

	nome1<-paste0(OUTPUT_DIR, "/Eval_EM_", sp.names[i], ".txt", sep="")
	write.table(myBiomodModelEval_ensamble , file=nome1, sep="\t")



	
###########################################################################
######################      PROJECTION ON ALPS        #####################
###########################################################################

###########################################################################
###########################           CURRENT   ###########################
###########################################################################


# 5. Individual models projections on current environmental conditions
#
# Workaround for MAXNET segfault on large rasters:
# maxnet/glmnet crashes with "caught segfault, address (nil)" when predicting
# on very large rasters (64M+ cells). This is a known issue with memory allocation
# in the glmnet C code. Aggregating the raster 2x reduces cells by 4x (64M -> 16M)
# which stays within glmnet's limits. Output resolution is coarser but avoids crash.
# Alternative solutions: chunk predictions, or exclude MAXNET from models.
cur_proj_agg <- aggregate(cur_proj, fact=2, fun="mean")
cat("DEBUG: Aggregated projection raster from", ncell(cur_proj), "to", ncell(cur_proj_agg), "cells\n")

start.time <- Sys.time()
myBiomodProj<- BIOMOD_Projection(
				bm.mod = myBiomodModelOut,
				proj.name = 'current',
				new.env = cur_proj_agg,
				models.chosen = 'all',
				build.clamping.mask = T,
                        nb.cpu=SAFE_CPU)

end.time <- Sys.time()
time.cur_proj <- end.time - start.time

# 6. Project ensemble models

start.time <- Sys.time()

myBiomodEMProj <- BIOMOD_EnsembleForecasting(
			bm.em = myBiomodEM,
			proj.name = 'CurrentEM',
      		new.env = cur_proj_agg,
			models.chosen = 'all',
			metric.binary = 'all',
			metric.filter = 'all',
			nb.cpu = SAFE_CPU)

end.time <- Sys.time()
time.cur_proj_EM <- end.time - start.time


###########################################################################
#######################################   FUTURE     ######################
###########################################################################

##Number of future projections
nf<-length(lf)


start.time <- Sys.time()
for(k in 1:nf){
name<-lf[k]
cat("\n\nDEBUG: Processing future scenario", k, "of", nf, ":", name, "\n")

fut_files <- dir(lf[k], full.names=T)
cat("DEBUG: Found", length(fut_files), "files:", paste(basename(fut_files), collapse=", "), "\n")

fut1 <- rast(fut_files)
cat("DEBUG: Raster loaded, ncell =", ncell(fut1), ", hasValues =", hasValues(fut1), "\n")


#names(fut1)<-lnames
fut<-fut1
fut_proj<-c(fut[[1]],fut[[2]],tri_proj,soil_proj[[1]],soil_proj[[2]])
fut_proj<-rast(fut_proj)
names(fut_proj)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

# Aggregate future raster (same as current) to avoid MAXNET segfault
fut_proj_agg <- aggregate(fut_proj, fact=2, fun="mean")

nm1<-strsplit(name, "/")[[1]]
nm<-paste0(nm1[5],"_", nm1[6])
nm2<-paste0('futureEM_',nm1[5],"_", nm1[6])

# 5. Individual models projections on future environmental conditions


myBiomodProj_fut<- BIOMOD_Projection(
						bm.mod = myBiomodModelOut,
						proj.name = nm,
						new.env = fut_proj_agg,
						models.chosen = 'all',
						build.clamping.mask = T,
                               	nb.cpu=SAFE_CPU)


myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
				bm.em = myBiomodEM,
				bm.proj = myBiomodProj_fut,
				proj.name = nm2,
				new.env = fut_proj_agg,
				models.chosen = 'all',
				metric.binary = 'all',
				metric.filter = 'all',
				nb.cpu = SAFE_CPU)
}
setTxtProgressBar(pb, i)# Sets the progress bar to the current state
Sys.sleep(10)
end.time <- Sys.time()
time.fut_proj<- end.time - start.time
#}
close(pb) # Close the connection


time<-data.frame(formating=time.formating, modeling=time.modeling, modeling_EM=time.modeling_EM, cur_projection=time.cur_proj,
			cur_projection_EM=time.cur_proj_EM, fut_projection=time.fut_proj)
write.table(time, paste0(OUTPUT_DIR, "/time_", sp.names[i], ".txt"), sep="\t")

#save.image(file="SDM_praterie.RData")


#r <- rast("Omalotheca hoppeana/proj_currentEM/proj_currentEM_Omalotheca hoppeana_ensemble.tif")
#plot(r)
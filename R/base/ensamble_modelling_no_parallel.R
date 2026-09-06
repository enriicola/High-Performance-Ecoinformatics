# Historical reference recovered from commit 890f4c5 (17 December 2025).
# This is the earliest tracked version; its DISTAV provenance still needs confirmation.
# Despite its filename, it creates a 10-worker cluster and passes nb.cpu = 10.
# It is therefore not a sequential baseline and must not be executed unchanged as one.
# Keep the historical body below unchanged; derive executable baselines in a separate file.

library(biomod2)
library(raster)
library(terra)
#library(rgdal)
library(gbm)
library(mda)
library(randomForest)
library(Hmisc)
library(plyr)
#library(maptools)
library(doParallel)
library(profvis)

cl <- makeCluster(10)
registerDoParallel(cl)



####################################
# loading species occurrences data
####################################
spocc <- read.table("C:/Users/User/Desktop/SDM_Alps/data_1km_EUNIS.txt", head=TRUE, sep="\t")
sp.names<-levels(factor(spocc[,1]))
num_sp<-length(sp.names)



#####################################
# CALIBRATION environmental data 
#####################################

#####################################
# loading CURRENT environmental data 
#####################################
clim_cal=rast(dir("C:/Users/User/Desktop/SDM_Alps/PCA/baseline", full.names=T))
tri_cal=rast(dir("C:/Users/User/Desktop/SDM_Alps/TRI", full.names=T))
soil_cal=rast(dir("C:/Users/User/Desktop/SDM_Alps/PCA/Suolo", full.names=T))
cur_cal<-c(clim_cal,tri_cal,soil_cal)
names(cur_cal)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

#####################################
# PROJECTION environmental data 
#####################################

#####################################
# loading CURRENT environmental data
#####################################
clim_proj=rast(dir("C:/Users/User/Desktop/SDM_Alps/Var_Climate/Baseline", full.names=T))
tri_proj=rast(dir("C:/Users/User/Desktop/SDM_Alps/Var_TRI", full.names=T))
soil_proj=rast(dir("C:/Users/User/Desktop/SDM_Alps/Var_Soil", full.names=T))
cur_proj<- c(clim_proj,tri_proj,soil_proj)
names(cur_proj)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

#####################################
# loading FUTURE list
#####################################

lf=list.dirs("C:/Users/User/Desktop/SDM_Alps/Var_Climate/future", full.names=T, recursive = T)[-1]
lf<-as.matrix(lf)
lf<-lf[nchar(lf[,1]) >= 66, ]
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

i=3
spocc1<-subset(spocc, spocc[,1]==sp.names[i])
spocc1 <- spocc1[1:100000,]

###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

###########################################################################
######################     ENSAMBLE       CURRENT     #####################
###########################################################################

start.time <- Sys.time()
myRespName <- paste (sp.names[i], sep = "")
myRespXY <- spocc1[,2:3] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

# 1. Formatting Data
 
 p <- profvis({ myBiomodData <- BIOMOD_FormatingData(
						resp.var = myResp,
                                       expl.var = cur_cal,
                                       resp.xy = myRespXY,
                                       resp.name = myRespName,
                                       PA.nb.rep = 5,
                                       PA.nb.absences = 10000,
                                       PA.strategy = 'random',
                          		   na.rm = TRUE,
						   filter.raster = F)})


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
	
p2 <- profvis({ myBiomodModelOut <- BIOMOD_Modeling(
						myBiomodData,
						models = selModels,
						CV.strategy = 'random',
						CV.nb.rep =5,
						CV.perc=0.7,
						OPT.user = opt.b,
						metric.eval  = c('TSS', 'ROC', 'KAPPA', 'POD', 'FAR'),
						scale.models = FALSE,
						CV.do.full.models = FALSE,
						nb.cpu=10,
						do.progress=T)})
	
end.time <- Sys.time()
time.modeling <- end.time - start.time

start.time <- Sys.time()
# 4. Model ensemble models

 p3 <- profvis({ myBiomodEM <- BIOMOD_EnsembleModeling(
						bm.mod = myBiomodModelOut,
                                    models.chosen = 'all',
                                    em.by = 'all',
                                    em.algo = c('EMmean', "EMcv"),
                                    metric.select = c('ROC'),
                                    metric.select.thresh = c(0.6),
                                    metric.eval = c('TSS', 'ROC', 'KAPPA'),
						nb.cpu = 10)})

end.time <- Sys.time()
time.modeling_EM <- end.time - start.time


###Models evaluations

	myBiomodModelEval <- get_evaluations(myBiomodModelOut)
	myBiomodModelEval_ensamble <- get_evaluations(myBiomodEM)

	nome<-paste0("C:/Users/User/Desktop/SDM_Alps/Eval_", sp.names[i], ".txt", sep="")
	write.table(myBiomodModelEval , file=nome, sep="\t")

	nome1<-paste0("C:/Users/User/Desktop/SDM_Alps/Eval_EM_", sp.names[i], ".txt", sep="")
	write.table(myBiomodModelEval_ensamble , file=nome1, sep="\t")



	
###########################################################################
######################      PROJECTION ON ALPS        #####################
###########################################################################

###########################################################################
###########################           CURRENT   ###########################
###########################################################################


# 5. Individual models projections on current environmental conditions

start.time <- Sys.time()
 p4 <- profvis({myBiomodProj<- BIOMOD_Projection(
				bm.mod = myBiomodModelOut,
				proj.name = 'current',
				new.env = cur_proj,
				models.chosen = 'all',
				build.clamping.mask = T,
                        nb.cpu=10)})

end.time <- Sys.time()
time.cur_proj <- end.time - start.time

# 6. Project ensemble models

start.time <- Sys.time()

myBiomodEMProj <- BIOMOD_EnsembleForecasting(
			bm.em = myBiomodEM,
			proj.name = 'CurrentEM',
      		new.env = cur_proj,
			models.chosen = 'all',
			metric.binary = 'all',
			metric.filter = 'all',
			nb.cpu = 10)

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

fut1 <- rast(dir(lf[k], full.names=T))


#names(fut1)<-lnames
fut<-fut1
fut_proj<-c(fut[[1]],fut[[2]],tri_proj,soil_proj[[1]],soil_proj[[2]])
fut_proj<-rast(fut_proj)
names(fut_proj)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

nm1<-strsplit(name, "/")[[1]]
nm<-paste0(nm1[5],"_", nm1[6])
nm2<-paste0('futureEM_',nm1[5],"_", nm1[6])

# 5. Individual models projections on future environmental conditions


p6 <- profvis({ myBiomodProj_fut<- BIOMOD_Projection(
						bm.mod = myBiomodModelOut,
						proj.name = nm,
						new.env = fut_proj,
						models.chosen = 'all',
						build.clamping.mask = T,
                               	nb.cpu=10)


myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
				bm.em = myBiomodEM,
				bm.proj = myBiomodProj_fut,
				proj.name = nm2,
				new.env = fut_proj,
				models.chosen = 'all',
				metric.binary = 'all',
				metric.filter = 'all'
				nb.cpu = 10)})
}
setTxtProgressBar(pb, i)# Sets the progress bar to the current state
Sys.sleep(10)
end.time <- Sys.time()
time.fut_proj<- end.time - start.time
#}
close(pb) # Close the connection


time<-data.frame(formating=time.formating, modeling=time.modeling, modeling_EM=time.modeling_EM, cur_projection=time.cur_proj,
			cur_projection_EM=time.cur_proj_EM, fut_projection=time.fut_proj)
write.table(time, "C:/Users/User/Desktop/SDM_Alps/time_Agrostis capillaris_10cpu.txt", sep="\t")

#save.image(file="SDM_praterie.RData")


r <- rast("Omalotheca hoppeana/proj_currentEM/proj_currentEM_Omalotheca hoppeana_ensemble.tif")
plot(r)
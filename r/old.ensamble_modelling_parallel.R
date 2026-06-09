library(biomod2)
library(raster)
library(terra)
library(rgdal)
library(gbm)
library(mda)
library(randomForest)
library(Hmisc)
library(plyr)
library(maptools)
library(doParallel)




cl <- makeCluster(10)
registerDoParallel(cl)


####################################
# loading species occurrences data
####################################
spocc <- read.table("File/Data_Species/data_Natura2000_1km.txt", head=TRUE, sep="\t")
sp.names<-levels(factor(spocc[,1]))
num_sp<-length(sp.names)



#####################################
# CALIBRATION environmental data 
#####################################

#####################################
# loading CURRENT environmental data 
#####################################
clim_cal=stack(dir("File/SDM_Vars/PCA/baseline", full.names=T))
tri_cal=stack(dir("File/TRI", full.names=T))
soil_cal=stack(dir("File/SDM_Vars/PCA/Suolo", full.names=T))
cur_cal<-stack(clim_cal,tri_cal,soil_cal)
names(cur_cal)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")


#####################################
# PROJECTION environmental data 
#####################################

#####################################
# loading CURRENT environmental data
#####################################
clim_proj=stack(dir("File/SDM_Vars/Var_Climate/Baseline", full.names=T))
tri_proj=stack(dir("File/SDM_Vars/Var_TRI", full.names=T))
soil_proj=stack(dir("File/SDM_Vars/Var_Soil", full.names=T))
cur_proj<-stack(clim_proj,tri_proj,soil_proj)
names(cur_proj)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

#####################################
# loading FUTURE list
#####################################

lf=list.dirs("SDM_Vars/Var_Climate/future", full.names=T, recursive = T)[-1]
lf<-as.matrix(lf)
lf<-lf[nchar(lf[,1]) >= 42, ]
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


selModels <- c("GLM", "GBM",  "ANN", "FDA", "MARS")


num_sp=20
foreach(i = 11:num_sp)  {      #i=1:num_sp	#i=1
spocc1<-subset(spocc, spocc[,1]==sp.names[i])


###########################################################################
######################     CALIBRATION ON EUROPE      #####################
###########################################################################

###########################################################################
######################     ENSAMBLE       CURRENT     #####################
###########################################################################

myRespName <- paste (sp.names[i], sep = "")
myRespXY <- spocc1[,2:3] # coordinates of points
myResp <- rep(1, nrow(spocc1)) # species occurences

# 1. Formatting Data
 
 myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                       expl.var = cur_cal,
                                       resp.xy = myRespXY,
                                       resp.name = myRespName,
                                       PA.nb.rep = 5,
                                       PA.nb.absences = 10000,
                                       PA.strategy = 'random',
                          		na.rm = TRUE,
						filter.raster = F)




# 2. Defining Models Options using default options.
# bigboss parameters
opt.b <- bm_ModelingOptions(data.type = 'binary',
                            models = selModels,
                            strategy = 'bigboss')

# 3. Computing the models
	myBiomodModelOut <- BIOMOD_Modeling(myBiomodData,
						models = selModels,
						OPT.user = opt.b,
						CV.nb.rep =5,
						CV.perc=0.7,
						CV.strategy = 'random',
						#var.import = 10,
                                    		nb.cpu=5,
						metric.eval  = c('TSS', 'ROC', 'KAPPA', 'POD', 'FAR'),
						scale.models = FALSE)
	

# 4. Model ensemble models
     myBiomodEM <- BIOMOD_EnsembleModeling(bm.mod = myBiomodModelOut,
                                    models.chosen = 'all',
                                    em.by = 'all',
                                    em.algo = c('EMmean', "EMcv"),
                                    metric.select = c('ROC'),
                                    metric.select.thresh = c(0.6),
                                    metric.eval = c('TSS', 'ROC', 'KAPPA'))




###Models evaluations

	myBiomodModelEval <- get_evaluations(myBiomodModelOut)
	myBiomodModelEval_ensamble <- get_evaluations(myBiomodEM)

	nome<-paste0("Eval/Eval_", sp.names[i], ".txt", sep="")
	write.table(myBiomodModelEval , file=nome, sep="\t")

	nome1<-paste0("Eval/Eval_EM_", sp.names[i], ".txt", sep="")
	write.table(myBiomodModelEval_ensamble , file=nome1, sep="\t")



	
###########################################################################
######################      PROJECTION ON ALPS        #####################
###########################################################################

###########################################################################
###########################           CURRENT   ###########################
###########################################################################


# 5. Individual models projections on current environmental conditions


myBiomodProj<- BIOMOD_Projection(
				bm.mod = myBiomodModelOut,
				new.env = cur_proj,
				proj.name = 'current',
				models.chosen = 'all',
				build.clamping.mask = T,
                        nb.cpu=1)

# 6. Project ensemble models

myBiomodEMProj <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM,
proj.name = 'currentEM',
new.env = cur_proj,
models.chosen = 'all',
metric.binary = 'all',
metric.filter = 'all')




###########################################################################
#######################################   FUTURE     ######################
###########################################################################

##Number of future projections
nf<-length(lf)

for(k in 1:nf){
name<-lf[k]

fut1=stack(dir(lf[k], full.names=T))


#names(fut1)<-lnames
fut<-fut1
fut_proj<-stack(fut[[1]],fut[[2]],tri_proj,soil_proj[[1]],soil_proj[[2]])
fut_proj<-stack(fut_proj)
names(fut_proj)<-c("PC1_clim", "PC2_clim", "tri","PC1_soil","PC2_soil")

nm1<-strsplit(name, "/")[[1]]
nm<-paste0(nm1[4],"_", nm1[5])
nm2<-paste0('futureEM_',nm1[4],"_", nm1[5])

# 5. Individual models projections on future environmental conditions


myBiomodProj_fut<- BIOMOD_Projection(
				bm.mod = myBiomodModelOut,
				new.env = fut_proj,
				proj.name = nm,
				models.chosen = 'all',
				build.clamping.mask = T,
                                nb.cpu=1)

myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM,
				proj.name = nm2,
				new.env = fut_proj,
				models.chosen = 'all',
				metric.binary = 'all',
				metric.filter = 'all')
}
setTxtProgressBar(pb, i)# Sets the progress bar to the current state
Sys.sleep(10)
}
close(pb) # Close the connection

save.image(file="SDM_praterie.RData")


r <- rast("Adonis.vernalis/proj_currentEM/proj_currentEM_Adonis.vernalis_ensemble.tif")
plot(r)
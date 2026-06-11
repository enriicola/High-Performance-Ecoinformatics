# debugging:
options(echo = TRUE) # ~ set -x : stampa ogni statement prima di eseguirlo
options(warn = 1) # stampa i warning quando accadono (non in blocco a fine run)
# options(verbose=TRUE)   # NO in batch: flood di messaggi interni R, poco utile
# nota: Rscript di default si ferma all'errore (~ set -e). MA foreach %dopar% cattura
#       gli errori dei worker e NON aborta il job -> controlla job.out/job.err per specie fallite.
# --- strumenti interattivi (NON funzionano in sbatch: niente stdin) ---
# trace(BIOMOD_FormatingData)  # traccia le chiamate di una funzione
# untrace(BIOMOD_FormatingData)
# debug(functionName)          # entra nel debugger a ogni chiamata
# browser()                    # breakpoint nel codice
###

library(biomod2)
library(raster)
library(terra)
# library(rgdal)        # ritirato da CRAN (ott 2023), assente nel container
library(gbm)
library(mda)
# library(randomForest) # non usato: modelli = GLM/GBM/ANN/FDA/MARS
library(Hmisc)
library(plyr)
# library(maptools)     # ritirato da CRAN (ott 2023), assente nel container
library(doParallel)

#####################################
# paths (current repo layout)
#####################################
root <- normalizePath(".")
in_dir <- file.path(root, "data/input")
out_dir <- file.path(root, "data/output")
dir.create(file.path(out_dir, "Eval"), recursive = TRUE, showWarnings = FALSE)

# verifica CRS raster (atteso 4326 = lon/lat WGS84, come i punti del CSV) -- vedi todo.md
message("CRS raster PC1: EPSG:", terra::crs(terra::rast(file.path(in_dir, "climate_vars/baseline/PC1.tif")), describe = TRUE)$code)

#####################################
# RUN CONFIG (quante specie elaborare)
#####################################
csv_file <- "small_1km_EUNIS.csv" # CSV ridotto per il test; metti "full_1km_EUNIS.csv" per il run completo
max_rows <- NA # NA = tutte le righe; es. 5000 = solo prime 5000 occorrenze (poche specie)
n_cpu <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "4")) # biomod2 internal parallelism

# NOTE: makeCluster/foreach parallelism DISABLED - hangs inside Singularity container.
# Using biomod2's internal nb.cpu instead (see BIOMOD_Modeling, BIOMOD_Projection calls).
# cl <- makeCluster(n_cpu)
# registerDoParallel(cl)

####################################
# loading species occurrences data
####################################
# CSV columns: id, sp_name, x, y, pseudo-absences  -> species = col2, coords = col3:4
spocc <- read.csv(file.path(in_dir, csv_file))
if (!is.na(max_rows)) spocc <- spocc[seq_len(min(max_rows, nrow(spocc))), ]
sp.names <- levels(factor(spocc[, 2]))
num_sp <- length(sp.names)

#####################################
# CALIBRATION environmental data
#####################################
clim_cal <- stack(dir(file.path(in_dir, "climate_vars/baseline"), full.names = T))
tri_cal <- stack(dir(file.path(in_dir, "TRI_vars"), full.names = T))
soil_cal <- stack(dir(file.path(in_dir, "soil_vars"), full.names = T))
cur_cal <- stack(clim_cal, tri_cal, soil_cal)
names(cur_cal) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

#####################################
# PROJECTION environmental data
# (single dataset: same dirs as calibration)
#####################################
clim_proj <- stack(dir(file.path(in_dir, "climate_vars/baseline"), full.names = T))
tri_proj <- stack(dir(file.path(in_dir, "TRI_vars"), full.names = T))
soil_proj <- stack(dir(file.path(in_dir, "soil_vars"), full.names = T))
cur_proj <- stack(clim_proj, tri_proj, soil_proj)
names(cur_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

#####################################
# loading FUTURE list (leaf dirs containing tif)
#####################################
lf <- list.dirs(file.path(in_dir, "climate_vars/future"), full.names = T, recursive = T)[-1]
lf <- lf[sapply(lf, function(d) length(dir(d, pattern = "\\.tif$")) > 0)] # filtro future
lf <- as.matrix(lf)

# outputs (biomod2 writes species folders into the working dir)
setwd(out_dir)

pb <- txtProgressBar(
  min = 0, # Minimum value of the progress bar
  max = num_sp, # Maximum value of the progress bar
  style = 3, # Progress bar style (also available style = 1 and style = 2)
  width = 50, # Progress bar width. Defaults to getOption("width")
  char = "="
) # Character used to create the bar

selModels <- c("GLM", "GBM", "ANN", "FDA", "MARS")

# Sequential loop over species. Parallelism via biomod2's internal nb.cpu.
# (foreach+doParallel hangs inside Singularity container on HPC)
for (i in 1:num_sp) {
  message("=== Processing species ", i, "/", num_sp, ": ", sp.names[i], " ===")
  tryCatch(
    {
      spocc1 <- subset(spocc, spocc[, 2] == sp.names[i])


      ###########################################################################
      ######################     CALIBRATION ON EUROPE      #####################
      ###########################################################################

      ###########################################################################
      ######################     ENSAMBLE       CURRENT     #####################
      ###########################################################################

      myRespName <- paste(sp.names[i], sep = "")
      myRespXY <- spocc1[, 3:4] # coordinates of points
      myResp <- rep(1, nrow(spocc1)) # species occurences

      # 1. Formatting Data

      myBiomodData <- BIOMOD_FormatingData(
        resp.var = myResp,
        expl.var = cur_cal,
        resp.xy = myRespXY,
        resp.name = myRespName,
        eval.resp.var = NULL,
        eval.expl.var = NULL,
        eval.resp.xy = NULL,
        PA.nb.rep = 10,
        PA.nb.absences = 10000,
        PA.strategy = "random",
        PA.dist.min = NULL,
        PA.dist.max = NULL,
        PA.sre.quant = 0.15,
        na.rm = TRUE,
        filter.raster = TRUE
      )


      # 2. Defining Models Options (bigboss preset)
      opt.b <- bm_ModelingOptions(
        data.type = "binary",
        models = selModels,
        strategy = "bigboss",
        bm.format = myBiomodData
      )

      # 3. Computing the models
      myBiomodModelOut <- BIOMOD_Modeling(myBiomodData,
        models = selModels,
        OPT.user = opt.b,
        CV.nb.rep = 10,
        CV.perc = 0.7,
        CV.strategy = "random",
        # var.import = 10,
        nb.cpu = n_cpu,
        metric.eval = c("TSS", "ROC", "KAPPA", "POD", "FAR"),
        scale.models = FALSE
      )


      # 4. Model ensemble models
      myBiomodEM <- BIOMOD_EnsembleModeling(
        bm.mod = myBiomodModelOut,
        models.chosen = "all",
        em.by = "all",
        em.algo = c("EMmean", "EMcv"),
        metric.select = c("ROC"),
        metric.select.thresh = c(0.6),
        metric.eval = c("TSS", "ROC", "KAPPA")
      )


      ### Models evaluations

      myBiomodModelEval <- get_evaluations(myBiomodModelOut)
      myBiomodModelEval_ensamble <- get_evaluations(myBiomodEM)

      nome <- paste0("Eval/Eval_", sp.names[i], ".txt", sep = "")
      write.table(myBiomodModelEval, file = nome, sep = "\t")

      nome1 <- paste0("Eval/Eval_EM_", sp.names[i], ".txt", sep = "")
      write.table(myBiomodModelEval_ensamble, file = nome1, sep = "\t")


      ###########################################################################
      ######################      PROJECTION ON ALPS        #####################
      ###########################################################################

      ###########################################################################
      ###########################           CURRENT   ###########################
      ###########################################################################


      # 5. Individual models projections on current environmental conditions


      myBiomodProj <- BIOMOD_Projection(
        bm.mod = myBiomodModelOut,
        new.env = cur_proj,
        proj.name = "current",
        models.chosen = "all",
        build.clamping.mask = T,
        nb.cpu = n_cpu
      )

      # 6. Project ensemble models

      myBiomodEMProj <- BIOMOD_EnsembleForecasting(
        bm.em = myBiomodEM,
        proj.name = "currentEM",
        new.env = cur_proj,
        models.chosen = "all",
        metric.binary = "all",
        metric.filter = "all"
      )


      ###########################################################################
      #######################################   FUTURE     ######################
      ###########################################################################

      ## Number of future projections
      nf <- length(lf)

      for (k in 1:nf) {
        name <- lf[k]

        fut1 <- stack(dir(lf[k], full.names = T))


        # names(fut1)<-lnames
        fut <- fut1
        fut_proj <- stack(fut[[1]], fut[[2]], tri_proj, soil_proj[[1]], soil_proj[[2]])
        fut_proj <- stack(fut_proj)
        names(fut_proj) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")

        # parsing nome future
        nm1 <- strsplit(name, "/")[[1]]
        nm <- paste0(nm1[length(nm1) - 1], "_", nm1[length(nm1)])
        nm2 <- paste0("futureEM_", nm1[length(nm1) - 1], "_", nm1[length(nm1)])

        # 5. Individual models projections on future environmental conditions


        myBiomodProj_fut <- BIOMOD_Projection(
          bm.mod = myBiomodModelOut,
          new.env = fut_proj,
          proj.name = nm,
          models.chosen = "all",
          build.clamping.mask = T,
          nb.cpu = n_cpu
        )

        myBiomodEMProj_fut <- BIOMOD_EnsembleForecasting(
          bm.em = myBiomodEM,
          proj.name = nm2,
          new.env = fut_proj,
          models.chosen = "all",
          metric.binary = "all",
          metric.filter = "all"
        )
      }
    },
    error = function(e) message("FALLITA specie ", sp.names[i], ": ", conditionMessage(e))
  )
  setTxtProgressBar(pb, i) # Sets the progress bar to the current state
  Sys.sleep(10)
}
close(pb) # Close the connection

save.image(file = "SDM_praterie.RData")


# interactive-only preview (skip on HPC batch)
# r <- rast("Adonis.vernalis/proj_currentEM/proj_currentEM_Adonis.vernalis_ensemble.tif")
# plot(r)

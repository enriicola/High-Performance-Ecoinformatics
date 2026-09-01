library(biomod2)
library(terra)

model_name <- load("data/output/Agrostis.capillaris/models/1781985804/Agrostis.capillaris_PA1_RUN1_MAXNET")
model <- get(model_name)
env <- rast(c(
  "data/input/climate_vars/baseline/PC1.tif",
  "data/input/climate_vars/baseline/PC2.tif",
  "data/input/TRI_vars/TRI.tif",
  "data/input/soil_vars/PC1_Edaphic.tif",
  "data/input/soil_vars/PC2_Edaphic.tif"
))
names(env) <- c("PC1_clim", "PC2_clim", "tri", "PC1_soil", "PC2_soil")
e <- ext(env)
dx <- (xmax(e) - xmin(e)) * 0.03
dy <- (ymax(e) - ymin(e)) * 0.03
env <- crop(env, ext(
  (xmin(e) + xmax(e)) / 2 - dx,
  (xmin(e) + xmax(e)) / 2 + dx,
  (ymin(e) + ymax(e)) / 2 - dy,
  (ymin(e) + ymax(e)) / 2 + dy
))

sample_data <- as.data.frame(values(env, na.rm = TRUE))[1:100, ]
original <- predict(model, env, on_0_1000 = FALSE, mod.name = "original")
original_data <- predict(model, sample_data, on_0_1000 = FALSE)
source("R/tmp/maxnet_blockwise_override.R")
blockwise <- predict(model, env, on_0_1000 = FALSE, mod.name = "blockwise")
blockwise_data <- predict(model, sample_data, on_0_1000 = FALSE)
blockwise_int <- predict(model, env, on_0_1000 = TRUE, mod.name = "blockwise_int")

original_values <- values(original, mat = FALSE)
blockwise_values <- values(blockwise, mat = FALSE)
blockwise_int_values <- values(blockwise_int, mat = FALSE)
stopifnot(
  identical(is.na(original_values), is.na(blockwise_values)),
  max(abs(original_values - blockwise_values), na.rm = TRUE) == 0,
  identical(round(original_values * 1000), blockwise_int_values),
  identical(original_data, blockwise_data)
)
cat("MAXNET block-wise prediction matches", sum(!is.na(original_values)), "cells\n")

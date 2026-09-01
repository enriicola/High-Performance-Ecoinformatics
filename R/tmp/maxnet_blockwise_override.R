library(biomod2)
library(terra)

.original_biomod_predict <- selectMethod("predict", "biomod2_model")

setMethod(
  "predict",
  signature(object = "MAXNET_biomod2_model"),
  function(object, ...) {
    args <- list(...)
    if ("newdata" %in% names(args)) {
      newdata <- args$newdata
      args$newdata <- NULL
    } else {
      newdata <- args[[1L]]
      args <- args[-1L]
    }
    if (!inherits(newdata, "SpatRaster")) {
      return(.original_biomod_predict(object, ...))
    }

    filename <- args$filename
    overwrite <- if (is.null(args$overwrite)) TRUE else args$overwrite
    on_0_1000 <- if (is.null(args$on_0_1000)) FALSE else args$on_0_1000

    if (!is.null(filename) && !overwrite && file.exists(filename)) {
      return(rast(filename))
    }
    if (any(is.factor(newdata))) {
      stop("Block-wise MAXNET prediction does not support categorical rasters")
    }
    if (length(get_scaling_model(object)) > 0) {
      stop("Block-wise MAXNET prediction does not support scaled models")
    }
    if (!is.null(args$seedval)) {
      set.seed(args$seedval)
    }

    predict_block <- function(model, data) {
      prediction <- predict(model, data, clamp = FALSE, type = "logistic")[, 1]
      if (on_0_1000) round(prediction * 1000) else prediction
    }

    terra::predict(
      newdata,
      get_formal_model(object),
      fun = predict_block,
      na.rm = TRUE,
      filename = if (is.null(filename)) "" else filename,
      overwrite = overwrite,
      wopt = if (on_0_1000) {
        list(names = args$mod.name, datatype = "INT2S", NAflag = -9999)
      } else {
        list(names = args$mod.name)
      }
    )
  }
)

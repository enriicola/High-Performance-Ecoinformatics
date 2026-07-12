step07_format_data <- function(ctx) {
  start.time <- Sys.time()
  ctx$myRespName <- paste(ctx$sp.names[ctx$i], sep = ".")
  ctx$myRespXY <- ctx$spocc1[, 2:3]
  ctx$myResp <- rep(1, nrow(ctx$spocc1))

  cat("DEBUG: starting BIOMOD_FormatingData at", format(Sys.time(), "%H:%M:%S"), "\n")
  flush.console()

  ctx$myBiomodData <- BIOMOD_FormatingData(
    resp.var = ctx$myResp,
    expl.var = ctx$cur_cal,
    resp.xy = ctx$myRespXY,
    resp.name = ctx$myRespName,
    PA.nb.rep = ctx$pa_nb_rep,
    PA.nb.absences = ctx$pa_nb_absences,
    PA.strategy = "random",
    na.rm = TRUE,
    filter.raster = F
  )

  cat("DEBUG: BIOMOD_FormatingData done at", format(Sys.time(), "%H:%M:%S"), "\n")
  ctx$time.formating <- Sys.time() - start.time

  invisible(ctx)
}

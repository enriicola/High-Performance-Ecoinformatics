step15_write_timing <- function(ctx) {
  close(ctx$pb)

  time <- data.frame(
    formating = as.numeric(ctx$time.formating, units = "secs"),
    modeling = as.numeric(ctx$time.modeling, units = "secs"),
    modeling_EM = as.numeric(ctx$time.modeling_EM, units = "secs"),
    cur_projection = as.numeric(ctx$time.cur_proj, units = "secs"),
    cur_projection_EM = as.numeric(ctx$time.cur_proj_EM, units = "secs"),
    fut_projection = as.numeric(ctx$time.fut_proj, units = "secs")
  )

  write.table(time, paste0("time_", ctx$sp.names[ctx$i], ".txt"), sep = "\t")

  invisible(ctx)
}

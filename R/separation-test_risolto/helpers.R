env_int <- function(name, default) {
  value <- Sys.getenv(name, "")
  if (!nzchar(value)) {
    return(as.integer(default))
  }
  as.integer(value)
}

env_num <- function(name, default) {
  value <- Sys.getenv(name, "")
  if (!nzchar(value)) {
    return(as.numeric(default))
  }
  as.numeric(value)
}

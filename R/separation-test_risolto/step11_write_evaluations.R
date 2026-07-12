step11_write_evaluations <- function(ctx) {
  nome <- paste0("Eval_", ctx$sp.names[ctx$i], ".txt", sep = "")
  write.table(ctx$myBiomodModelEval, file = nome, sep = "\t")

  nome1 <- paste0("Eval_EM_", ctx$sp.names[ctx$i], ".txt", sep = "")
  write.table(ctx$myBiomodModelEval_ensamble, file = nome1, sep = "\t")

  invisible(ctx)
}

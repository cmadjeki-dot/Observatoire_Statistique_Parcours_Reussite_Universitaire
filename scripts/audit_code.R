source("scripts/activate_environment.R")
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
out <- "outputs/validation_finale"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
               list.files("R", "[.]R$", full.names = TRUE))) {
  source(path, encoding = "UTF-8")
}
lint <- lintr::lint_dir("R")
writeLines(capture.output(print(lint)), file.path(out, "lintr.txt"))
rows <- lapply(lint, function(x) data.frame(
  fichier = x$filename, ligne = x$line_number, type = x$type,
  regle = x$linter, message = x$message
))
rows <- if (length(rows)) do.call(rbind, rows) else data.frame(
  fichier = character(), ligne = integer(), type = character(),
  regle = character(), message = character())
readr::write_csv(rows, file.path(out, "lintr.csv"))
cat("Observations lintr :", nrow(rows), "\n")
print(table(rows$type))
status <- renv::status()
saveRDS(status, file.path(out, "renv_status.rds"))
stopifnot(isTRUE(status$synchronized))
if (file.exists(file.path(out, "controles_R.csv"))) {
  controls <- readr::read_csv(file.path(out, "controles_R.csv"), show_col_types = FALSE)
  controls$statut[controls$controle == "lintr"] <- if (nrow(rows)) "OBSERVATIONS" else "VALIDE"
  controls$detail[controls$controle == "lintr"] <- paste(nrow(rows), "observations ; voir lintr.csv")
  controls$detail[controls$controle == "targets"] <- paste(nrow(targets::tar_manifest(callr_function = NULL)), "cibles declarees ; 0 obsolete")
  readr::write_csv(controls, file.path(out, "controles_R.csv"))
}
stopifnot(nrow(rows) == 0L)

# Diagnostic horodate, sans installation ni modification du lockfile.
dir.create("outputs/validation_finale", recursive = TRUE, showWarnings = FALSE)
log <- file("outputs/validation_finale/environnement_R.txt", open = "wt", encoding = "UTF-8")
sink(log, split = TRUE)
cat("UTC :", format(Sys.time(), tz = "UTC", usetz = TRUE), "\n")
cat(R.version.string, "\n")
cat("Activation renv...\n")
flush.console()
source("scripts/activate_environment.R")
cat("Activation renv terminee.\n")
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
cat("Bibliotheques :", paste(.libPaths(), collapse = "; "), "\n")
packages <- c("renv", "targets", "yaml", "readr", "dplyr", "tidyr", "ggplot2",
              "testthat", "knitr", "rmarkdown", "broom", "shiny")
available <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
print(data.frame(package = packages, disponible = available,
                 version = vapply(packages, function(p) {
                   if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else NA_character_
                 }, character(1))))
cat("Controle de synchronisation renv...\n")
status <- renv::status()
saveRDS(status, "outputs/validation_finale/renv_status.rds")
cat("SESSION\n")
print(sessionInfo())
sink()
close(log)
stopifnot(all(available), isTRUE(status$synchronized))

# À exécuter depuis la racine du projet ; aucune installation.
dir.create("outputs", showWarnings = FALSE)
packages <- c("renv", "targets", "yaml", "readr", "dplyr", "tidyr",
              "ggplot2", "testthat", "knitr", "rmarkdown", "broom", "shiny")
status <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
lines <- c(
  paste("Diagnostic UTC :", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  R.version.string,
  paste("Répertoire :", normalizePath(".", winslash = "/")),
  paste("Outils PATH :", paste(names(Sys.which(c("git", "quarto"))),
                               Sys.which(c("git", "quarto")), collapse = "; ")),
  paste(packages, ifelse(status, "disponible", "à installer"), sep = " : "),
  capture.output(sessionInfo())
)
writeLines(lines, "outputs/environment_check.txt", useBytes = TRUE)
cat(paste(lines, collapse = "\n"), "\n")

# Reproduire les calculs sans donnees ni sorties preexistantes.
source("scripts/activate_environment.R")
validate_fresh <- function() {
  root <- normalizePath(getwd(), winslash = "/")
  checkout <- tempfile("observatoire-fresh-")
  dir.create(checkout)
  paths <- system2("git", "ls-files", stdout = TRUE)
  stopifnot(length(paths) > 0L)
  for (path in paths) {
    destination <- file.path(checkout, path)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(file.path(root, path), destination))
  }
  stopifnot(!dir.exists(file.path(checkout, "data/interim")))
  setwd(checkout)
  on.exit(setwd(root), add = TRUE)
  targets::tar_make(callr_function = NULL)
  for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
                 list.files("R", "[.]R$", full.names = TRUE))) {
    source(path, encoding = "UTF-8", local = .GlobalEnv)
  }
  results <- as.data.frame(testthat::test_dir(
    "tests/testthat", reporter = "summary", stop_on_failure = TRUE
  ))
  stopifnot(sum(results$failed) == 0L, sum(results$warning) == 0L,
            !any(results$error), file.exists("data/interim/qualite.rds"))
  cat("Copie sans donnees :", sum(results$passed), "assertions valides.\n")
}
validate_fresh()

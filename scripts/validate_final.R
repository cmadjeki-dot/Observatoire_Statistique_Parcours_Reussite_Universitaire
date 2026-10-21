# Recette R finale : resultats structures et journalises, sans installation.
source("scripts/activate_environment.R")
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
dir.create("outputs/validation_finale", recursive = TRUE, showWarnings = FALSE)
out <- "outputs/validation_finale"
cat("Pipeline targets\n")
started <- Sys.time()
targets::tar_make(callr_function = NULL)
meta <- targets::tar_meta(fields = c(name, error, seconds))
readr::write_csv(meta, file.path(out, "targets_meta.csv"))
outdated <- targets::tar_outdated(callr_function = NULL)
stopifnot(all(is.na(meta$error) | meta$error == ""), length(outdated) == 0L)
cat("Tests R\n")
for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
               list.files("R", "[.]R$", full.names = TRUE))) source(path, encoding = "UTF-8")
tests <- testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)
results <- as.data.frame(tests)
readr::write_csv(results[, setdiff(names(results), "result")], file.path(out, "tests.csv"))
stopifnot(sum(results$failed) == 0L, !any(results$error), sum(results$warning) == 0L)
cat("Audit statique R\n")
files <- c(list.files("R", "[.]R$", full.names = TRUE, recursive = TRUE),
           list.files("scripts", "[.]R$", full.names = TRUE), "_targets.R", ".Rprofile")
for (path in files) parse(path, encoding = "UTF-8")
absolute <- lapply(list.files("R", "[.]R$", full.names = TRUE, recursive = TRUE), function(path) {
  text <- readLines(path, warn = FALSE, encoding = "UTF-8")
  lines <- grep("[A-Za-z]:[/\\\\]", text)
  data.frame(fichier = rep(path, length(lines)), ligne = lines)
})
absolute <- do.call(rbind, absolute)
readr::write_csv(absolute, file.path(out, "chemins_absolus_metier.csv"))
stopifnot(nrow(absolute) == 0L)
lint_status <- "NON_EXECUTE_PACKAGE_ABSENT"
if (requireNamespace("lintr", quietly = TRUE)) {
  lint <- lintr::lint_dir("R")
  writeLines(capture.output(print(lint)), file.path(out, "lintr.txt"))
  lint_status <- if (length(lint)) "OBSERVATIONS" else "VALIDE"
  stopifnot(length(lint) == 0L)
}
renv_status <- renv::status()
saveRDS(renv_status, file.path(out, "renv_status.rds"))
stopifnot(isTRUE(renv_status$synchronized))
summary <- data.frame(
  controle = c("targets", "tests", "syntaxe_R", "chemins_metier", "renv", "lintr"),
  statut = c("VALIDE", "VALIDE", "VALIDE", "VALIDE", "VALIDE", lint_status),
  detail = c(paste(nrow(targets::tar_manifest(callr_function = NULL)), "cibles declarees ; 0 obsolete"),
    paste(sum(results$passed), "assertions ;", nrow(results), "cas ; 0 echec"),
    paste(length(files), "sources"), "0 chemin Windows absolu dans R/",
    "synchronized=TRUE", lint_status)
)
readr::write_csv(summary, file.path(out, "controles_R.csv"))
cat("Duree R :", as.numeric(difftime(Sys.time(), started, units = "secs")), "secondes\n")
print(summary)

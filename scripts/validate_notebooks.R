# Validation des calculs des notebooks, independamment du cache CSS de Quarto.
source("scripts/activate_environment.R")
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
root <- normalizePath(".", winslash = "/")
out <- file.path(root, "outputs/validation_finale/notebooks_knit")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
knitr::opts_knit$set(root.dir = root)
knitr::opts_chunk$set(error = FALSE, warning = FALSE, message = FALSE)
paths <- list.files("notebooks", "[.]qmd$", full.names = TRUE)
results <- lapply(paths, function(path) {
  cat("Notebook :", path, "\n")
  error <- tryCatch({
    knitr::knit(input = path, output = file.path(out, paste0(basename(path), ".md")),
                envir = new.env(parent = globalenv()), quiet = TRUE)
    NA_character_
  }, error = function(e) conditionMessage(e))
  data.frame(notebook = path, statut = if (is.na(error)) "VALIDE_CALCULS" else "ECHEC",
             erreur = error)
})
results <- do.call(rbind, results)
readr::write_csv(results, file.path(root, "outputs/validation_finale/notebooks.csv"))
print(results)
stopifnot(all(results$statut == "VALIDE_CALCULS"))

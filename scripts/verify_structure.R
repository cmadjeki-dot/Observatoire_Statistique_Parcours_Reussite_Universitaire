# Controle de structure sans installation ni execution du pipeline.
stopifnot(file.exists(".here"))
required <- c(
  "DESCRIPTION", "renv.lock", ".Rprofile", "renv/activate.R",
  "_targets.R", "_quarto.yml", "config/parameters.yml",
  "config/indicator_definitions.yml", "R/functions/common.R",
  ".vscode/settings.json", ".vscode/extensions.json", ".vscode/tasks.json",
  "docs/00_fiche_identite.md", "docs/19_architecture_vscode.md",
  "notebooks/00_cadrage_du_projet.qmd"
)
missing <- required[!file.exists(required)]
if (length(missing)) stop("Fichiers absents : ", paste(missing, collapse = ", "))
scripts <- unlist(lapply(c("R", "scripts", "tests"), function(folder) {
  list.files(folder, pattern = "[.]R$", recursive = TRUE, full.names = TRUE)
}))
for (path in c(scripts, "_targets.R", ".Rprofile")) {
  parse(path, encoding = "UTF-8")
}
cat(R.version.string, "\n")
cat(length(required), "fichiers de structure presents ;", length(scripts) + 2L,
    "sources R analysables. Aucun calcul ni installation effectue.\n")

run_phase_seven <- function(tables, config) {
  original <- readBin("config/parameters.yml", "raw", n =
                        file.info("config/parameters.yml")$size)
  restored <- FALSE
  on.exit(
    if (!restored) writeBin(original, "config/parameters.yml"),
    add = TRUE
  )
  targets::tar_make(callr_function = NULL)
  initial <- targets::tar_read_raw("synthetic")
  targets::tar_make(callr_function = NULL)
  initial_outdated <- targets::tar_outdated(callr_function = NULL)
  text <- readLines("config/parameters.yml", encoding = "UTF-8")
  text <- sub(
    paste0("seed: ", config$seed),
    paste0("seed: ", config$seed + 1L),
    text,
    fixed = TRUE
  )
  writeLines(text, "config/parameters.yml", useBytes = TRUE)
  changed_outdated <- targets::tar_outdated(callr_function = NULL)
  targets::tar_make(callr_function = NULL)
  changed <- targets::tar_read_raw("synthetic")
  stopifnot(
    !identical(initial, changed),
    "synthetic" %in% changed_outdated
  )
  writeBin(original, "config/parameters.yml")
  restored <- TRUE
  targets::tar_make(callr_function = NULL)
  stopifnot(identical(initial, targets::tar_read_raw("synthetic")))
  write_csv(
    data.frame(
      controle = c("sans_modification", "graine_modifiee", "restauration"),
      resultat = c(
        paste(
          length(initial_outdated),
          "cibles obsoletes"
        ),
        paste(
          length(changed_outdated),
          "cibles invalidees ; donnees differentes"
        ),
        "donnees initiales strictement retrouvees"
      )
    ),
    "outputs/tables/recette_targets.csv"
  )
  testthat::test_file("tests/testthat/test-export.R", stop_on_failure = TRUE)
  phase_receipt(
    7, c(
      paste0(
        "Pipeline targets execute ; reprise sans modification puis modifi",
        "cation/restitution de graine testees."
      ),
      paste0(
        "Exports agreges et proteges generes ; tests de masquage compleme",
        "ntaire passes."
      ),
      paste0(
        "Power BI Desktop installe, mais aucune session de pilotage conne",
        "ctee disponible."
      ),
      paste0(
        "Guide de montage, Power Query, DAX et matrice attendue R livres.",
        " PBIX et controles dans Desktop NON REALISES."
      ),
      paste0(
        "Statut : partie R validee ; recette visuelle Power BI en attente",
        ". La restitution phase 8 documente cette limite."
      )
    )
  )
}

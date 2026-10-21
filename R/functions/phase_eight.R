run_phase_eight <- function(tables, config) {
  testthat::test_dir("tests/testthat", stop_on_failure = TRUE)
  ins <- tables$inscriptions
  ind <- readRDS("data/interim/indicateurs.rds")
  ev <- readRDS("data/interim/enquetes.rds")
  last <- tail(ind$counts$annuel, 1)
  ids <- ins$inscription_id[ins$annee == last$annee]
  response <- tables$evaluation[tables$evaluation$inscription_id %in% ids, ]
  latest_ev <- ev$evaluation$counts[ev$evaluation$counts$annee == last$annee, ]
  proof <- data.frame(
    constat = c(
      "inscrits_derniere_annee", "validations_derniere_annee",
      "invitations_delivrees",
      "avis_valides", "avis_satisfaits"
    ),
    rapport = c(
      last$inscrits, last$validations, sum(latest_ev$sollicites),
      sum(latest_ev$avis),
      sum(latest_ev$satisfaits)
    ),
    calcul_direct = c(
      length(
        unique(
          ins$etudiant_id[ins$inscription_id %in%
                            ids]
        )
      ),
      sum(
        tables$resultats$validation[tables$resultats$inscription_id %in%
                                      ids] == "oui"
      ),
      sum(response$sollicitation_delivree),
      sum(!is.na(response$satisfaction_1_5)),
      sum(response$satisfaction_1_5 %in% 4:5)
    )
  )
  stopifnot(all(proof$rapport == proof$calcul_direct))
  write_csv(proof, "outputs/tables/recette_chiffres_rapports.csv")
  rscript <- file.path(
    R.home("bin"),
    "Rscript.exe"
  )
  Sys.setenv(QUARTO_R = rscript)
  status <- system2(
    Sys.which("quarto"),
    "render"
  )
  if (status != 0L) {
    stop("Echec du rendu Quarto")
  }
  phase_receipt(
    8, c(
      paste0(
        "Tous les tests R executes avec succes ; chiffres des rapports ra",
        "pproches des tables preparees."
      ),
      paste0(
        "Rapport, note, presentation et rapport enquetes rendus en HTML p",
        "ar Quarto."
      ),
      paste0(
        "Verification PDF et pagination : voir outputs/tables/recette_pdf",
        ".json apres export navigateur."
      ),
      "Portfolio prepare localement ; aucune publication GitHub.",
      paste0(
        "Recette Power BI visuelle et import LimeSurvey non realises ; au",
        "cune conformite institutionnelle revendiquee."
      )
    )
  )
}

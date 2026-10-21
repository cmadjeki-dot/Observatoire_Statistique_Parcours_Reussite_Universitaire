run_later_phase <- function(phase, config) {
  tables <- readRDS("data/processed/tables.rds")
  stopifnot(
    nrow(validate_data(tables, config)) ==
      0
  )
  if (phase == 4L) {
    out <- compute_indicators(tables, config)
    for (n in names(out$counts)) {
      write_csv(out$counts[[n]], paste0("outputs/tables/scolarite_", n, ".csv"))
    }
    write_csv(out$metrics, "outputs/tables/indicateurs.csv")
    write_csv(out$evolution, "outputs/tables/evolution.csv")
    descriptive_analysis(out)
    saveRDS(out, "data/interim/indicateurs.rds")
    testthat::test_file("tests/testthat/test-indicators.R",
                        stop_on_failure = TRUE)
    phase_receipt(
      4, c(
        paste0(
          "Effectifs, validation, diplomation, couverture et transitions ",
          "calcules."
        ),
        paste0(
          "Tests manuels, censure, denominateur nul et rapprochements exe",
          "cutes avec succes."
        ),
        paste0(
          "Les tables de travail restent locales ; les exports de diffusi",
          "on seront proteges en phase 7."
        )
      )
    )
  } else if (phase == 5L) {
    ev <- survey_counts(tables)
    emp <- graduate_counts(tables)
    write_csv(ev$counts, "outputs/tables/evaluation.csv")
    write_csv(ev$profiles, "outputs/tables/non_reponse_profils.csv")
    write_csv(emp, "outputs/tables/insertion.csv")
    saveRDS(
      list(evaluation = ev, insertion = emp),
      "data/interim/enquetes.rds"
    )
    testthat::test_file("tests/testthat/test-surveys.R", stop_on_failure = TRUE)
    phase_receipt(
      5, c(
        paste0(
          "Questionnaire et protocole prepares, transposition LimeSurvey ",
          "non importee."
        ),
        paste0(
          "Participation, avis et non-reponse analyses ; horizons de dipl",
          "omes testes."
        ),
        paste("Diplomes non encore matures :", sum(emp$non_matures)),
        paste0(
          "Tests de reponses partielles, doublons, zero sollicitation et ",
          "maturite passes."
        )
      )
    )
  } else if (phase == 6L) {
    out <- model_analysis(tables, config)
    saveRDS(out, "data/interim/modeles.rds")
    for (n in setdiff(
      names(out),
      "model"
    )) {
      write_csv(out[[n]], paste0("outputs/tables/modele_", n, ".csv"))
    }
    testthat::test_file("tests/testthat/test-models.R", stop_on_failure = TRUE)
    phase_receipt(
      6, c(
        paste0(
          "Une premiere inscription par etudiant ; cible connue et profil",
          "s complets pour le modele principal."
        ),
        paste0(
          "Separation apprentissage/evaluation par etudiant, sans chevauc",
          "hement ; diagnostics executes."
        ),
        paste("AUC sur evaluation :", round(out$diagnostics$auc, 3)),
        paste0(
          "Sensibilite avec categories de profils manquants ; aucune inte",
          "rpretation causale."
        )
      )
    )
  } else if (phase == 7L) {
    run_phase_seven(tables, config)
  } else if (phase == 8L) {
    run_phase_eight(tables, config)
  } else {
    stop("Phase non reconnue")
  }
}

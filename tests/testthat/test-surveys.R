testthat::test_that("les avis partiels ne gonflent pas le denominateur de satisfaction", {
  x <- list(evaluation = data.frame(inscription_id = paste0("I", 1:4), vague = "v1",
      sollicitation_delivree = c(TRUE,TRUE,TRUE,FALSE), reponse = c(TRUE,TRUE,FALSE,FALSE),
      satisfaction_1_5 = c(5L,NA,NA,NA), motif_satisfaction = c("avis","item_manquant","non_reponse","non_sollicite")),
    inscriptions = data.frame(inscription_id = paste0("I",1:4), etudiant_id = paste0("E",1:4), annee = "A", formation_id = "F"),
    etudiants = data.frame(etudiant_id = paste0("E",1:4), type_bac = "general", boursier = 0L))
  out <- survey_counts(x)$counts
  testthat::expect_equal(out$participation, 2/3)
  testthat::expect_equal(out$satisfaction, 1)
  testthat::expect_equal(out$avis, 1L)
  x$evaluation$sollicitation_delivree <- FALSE; x$evaluation$reponse <- FALSE
  x$evaluation$satisfaction_1_5 <- NA_integer_
  testthat::expect_true(is.na(survey_counts(x)$counts$participation))
  x$evaluation <- rbind(x$evaluation, x$evaluation[1, ])
  testthat::expect_error(survey_counts(x), "Doublons")
})
testthat::test_that("la maturite est calendaire et les non-matures ne repondent pas", {
  testthat::expect_equal(add_months(as.Date("2025-07-15"), 6), as.Date("2026-01-15"))
  cfg <- read_config(); cfg$n_students <- 300L
  x <- generate_data(cfg)
  testthat::expect_true(all(!x$insertion$sollicitation_delivree[!x$insertion$eligible]))
  g <- graduate_counts(x)
  testthat::expect_equal(g$eligibles + g$non_matures, g$diplomes)
  testthat::expect_true(all(is.na(g$taux_emploi[g$eligibles == 0])))
  x$insertion <- rbind(x$insertion, x$insertion[1, ])
  testthat::expect_error(graduate_counts(x), "Doublons")
})

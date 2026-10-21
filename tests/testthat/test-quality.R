testthat::test_that("anomalies, conflits et dependances sont traites sans source de verite", {
  cfg <- read_config(); cfg$n_students <- 100L
  original <- generate_data(cfg)
  testthat::expect_equal(nrow(validate_data(original, cfg)), 0L)
  bad <- inject_anomalies(original)
  testthat::expect_gt(nrow(validate_data(bad$raw, cfg)), 0L)
  clean <- prepare_data(bad$raw, cfg)
  testthat::expect_equal(nrow(validate_data(clean$tables, cfg)), 0L)
  testthat::expect_false(original$etudiants$etudiant_id[2] %in% clean$tables$etudiants$etudiant_id)
  testthat::expect_equal(sum(clean$journal$controle == "doublon_exact"), 8L)
  testthat::expect_true(all(clean$tables$inscriptions$inscription_id %in% clean$tables$resultats$inscription_id))
})
testthat::test_that("non-reponse plausible et annee censuree ne sont pas des erreurs", {
  cfg <- read_config(); cfg$n_students <- 100L
  x <- generate_data(cfg)
  testthat::expect_true(all(x$parcours$statut[x$parcours$censure] == "censuree"))
  testthat::expect_true(all(!x$insertion$reponse[!x$insertion$eligible]))
  testthat::expect_equal(nrow(validate_data(x, cfg)), 0L)
})

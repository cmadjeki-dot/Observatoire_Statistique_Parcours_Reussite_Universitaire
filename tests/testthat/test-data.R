testthat::test_that("la simulation respecte le perimetre et la graine", {
  cfg <- read_config()
  cfg$n_students <- 150L
  x <- generate_data(cfg)
  testthat::expect_identical(x, generate_data(cfg))
  testthat::expect_length(x, 8L)
  testthat::expect_equal(nrow(x$etudiants), 150L)
  testthat::expect_equal(nrow(x$formations), 5L)
  testthat::expect_setequal(x$inscriptions$annee, cfg$academic_years)
  testthat::expect_equal(length(unique(x$inscriptions$etudiant_id)), 150L)
  for (name in names(table_keys)) {
    testthat::expect_equal(anyDuplicated(x[[name]][[table_keys[[name]]]]), 0L)
  }
  testthat::expect_equal(anyDuplicated(paste(x$inscriptions$etudiant_id,
                                            x$inscriptions$annee)), 0L)
  testthat::expect_setequal(x$resultats$inscription_id, x$inscriptions$inscription_id)
  testthat::expect_true(all(x$inscriptions$etudiant_id %in% x$etudiants$etudiant_id))
  testthat::expect_true(all(x$inscriptions$formation_id %in% x$formations$formation_id))
  changed <- cfg
  changed$seed <- cfg$seed + 1L
  testthat::expect_false(identical(x, generate_data(changed)))
})

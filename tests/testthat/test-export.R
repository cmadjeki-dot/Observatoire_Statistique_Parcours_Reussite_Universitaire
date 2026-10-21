testthat::test_that("une cellule petite masque aussi les complements et totaux de l'annee", {
  x <- data.frame(annee = c("A", "A", "B"), formation_id = c("F1", "F2", "F1"),
    inscrits = c(100L,100L,100L), validations = c(98L,50L,50L))
  safe <- protect_fact(x, 5L, "inscrits")
  testthat::expect_equal(safe$masque, c(TRUE,TRUE,FALSE))
  testthat::expect_true(all(is.na(safe$inscrits[1:2])))
  testthat::expect_true(all(is.na(safe$validations[1:2])))
  testthat::expect_true(is.na(safe_sum(safe[safe$annee == "A", ], "inscrits")))
  testthat::expect_true(is.na(safe_sum(safe, "inscrits")))
  testthat::expect_equal(safe_sum(safe[safe$annee == "B", ], "inscrits"), 100)
})
testthat::test_that("le paquet Power BI ne contient pas de lignes individuelles ou de taux moyens", {
  facts <- readRDS(project_path("data/interim/exports_proteges.rds"))
  for (fact in facts) {
    testthat::expect_false(any(c("etudiant_id", "inscription_id", "taux", "valeur") %in% names(fact)))
    testthat::expect_equal(anyDuplicated(paste(fact$annee, fact$formation_id)), 0L)
    nums <- names(fact)[vapply(fact, is.numeric, logical(1))]
    testthat::expect_true(all(vapply(fact[nums], function(v) all(is.na(v[fact$masque])), logical(1))))
  }
})

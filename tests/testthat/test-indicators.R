testthat::test_that("les comptes correspondent a un temoin calcule a la main", {
  b <- data.frame(annee = rep("2023-2024", 6), formation_id = "F01",
    etudiant_id = paste0("E", 1:6), validation = c("oui", "non", "oui", "inconnue", "oui", "non"),
    niveau = c(1,1,1,3,3,3), niveau_terminal = 3,
    censure = c(FALSE,FALSE,FALSE,FALSE,TRUE,TRUE),
    statut = c("passage", "redoublement", "reorientation", "sortie_observee", "censuree", "censuree"))
  counts <- school_counts(b)
  testthat::expect_equal(counts$inscrits, 6)
  testthat::expect_equal(counts$validations, 3)
  testthat::expect_equal(counts$connus, 5)
  testthat::expect_equal(counts$eligibles_passage, 3)
  testthat::expect_equal(counts$suivis, 4)
  metrics <- school_metrics(counts)
  value <- function(n) metrics$valeur[metrics$indicateur == n]
  testthat::expect_equal(value("validation_eligibles"), .5)
  testthat::expect_equal(value("validation_connus"), .6)
  testthat::expect_equal(value("passage"), 1/3)
  testthat::expect_equal(value("reorientation"), 1/4)
  testthat::expect_equal(value("validation_borne_haute"), 4/6)
  b$censure <- TRUE; b$statut <- "censuree"
  testthat::expect_true(is.na(school_metrics(school_counts(b))$valeur[school_metrics(school_counts(b))$indicateur == "passage"]))
  testthat::expect_true(is.na(ratio(0, 0)))
})
testthat::test_that("les totaux et les sous-populations sont reconciliables", {
  cfg <- read_config(); cfg$n_students <- 200L
  out <- compute_indicators(generate_data(cfg), cfg)
  totals <- out$counts$formation |>
    dplyr::group_by(annee) |>
    dplyr::summarise(inscrits = sum(inscrits), validations = sum(validations), .groups = "drop")
  testthat::expect_equal(totals$inscrits, out$counts$annuel$inscrits)
  testthat::expect_equal(totals$validations, out$counts$annuel$validations)
  c <- out$counts$formation
  testthat::expect_equal(c$passages + c$redoublements + c$reorientations +
    c$sorties_observees + c$situations_inconnues + c$fins_diplomees, c$suivis)
})

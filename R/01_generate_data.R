generate_data <- function(config) {
  set.seed(config$seed)
  n <- config$n_students
  years <- config$academic_years
  sim <- config$simulation
  formations <- data.frame(
    formation_id = sprintf("F%02d", 1:5),
    libelle_fictif = c(
      "Licence Alpha", "Licence Beta", "Licence Gamma", "Master Delta",
      "Master Epsilon"
    ),
    composante_fictive = c("Pole A", "Pole A", "Pole B", "Pole B", "Pole C"),
    cycle = c(
      rep("Licence", 3),
      rep("Master", 2)
    ),
    niveau_terminal = c(3L, 3L, 3L, 2L, 2L)
  )
  entry <- sample(1:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.3))
  initial_f <- sample(1:5, n, replace = TRUE, prob = c(0.26, 0.24, 0.22,
                                                       0.15, 0.13))
  initial_level <- ifelse(initial_f <= 3, 1L, 1L)
  present <- which(entry == 1)
  initial_level[present] <- vapply(
    present,
    function(i) sample.int(formations$niveau_terminal[initial_f[i]], 1),
    integer(1)
  )
  age <- ifelse(initial_f <= 3, 18L, 21L) +
    initial_level - 1L + sample(0:5, n, TRUE, c(0.55, 0.2, 0.1, 0.07, 0.05,
                                                0.03))
  type_bac <- sample(
    c("general", "technologique", "professionnel"),
    n, TRUE, c(0.72, 0.21, 0.07)
  )
  boursier <- rbinom(n, 1, 0.35)
  etudiants <- data.frame(
    etudiant_id = sprintf("E%05d", seq_len(n)),
    annee_naissance = as.integer(substr(years[entry], 1, 4)) -
      age, type_bac = type_bac, boursier = boursier, annee_entree_observee =
      years[entry],
    primo_entrant_observe = entry > 1 | initial_level == 1L
  )
  etudiants$type_bac[runif(n) <
                       sim$profile_missing_probability] <- NA_character_
  etudiants$boursier[runif(n) <
                       sim$profile_missing_probability] <- NA_integer_
  enroll <- results <- list()
  current_f <- initial_f
  current_level <- initial_level
  active <- rep(FALSE, n)
  for (y in seq_along(years)) {
    active[entry == y] <- TRUE
    idx <- which(active)
    f <- current_f[idx]
    lev <- current_level[idx]
    ins <- data.frame(
      inscription_id = paste0("I", y, "_", etudiants$etudiant_id[idx]),
      etudiant_id = etudiants$etudiant_id[idx], formation_id =
        formations$formation_id[f],
      annee = years[y], niveau = lev, regime = sample(
        c("initiale", "reprise"),
        length(idx),
        TRUE, c(0.94, 0.06)
      )
    )
    eta <- 0.8 + sim$formation_success_offsets[f] + 0.18 * (lev - 1) + ifelse(
      type_bac[idx] == "general", 0.3,
      ifelse(type_bac[idx] == "technologique", -0.15, -0.45)
    ) -
      0.1 * boursier[idx] + 0.05 * (y - 1)
    passed <- rbinom(
      length(idx),
      1, plogis(eta)
    ) ==
      1
    missing <- runif(length(idx)) <
      sim$result_missing_probability
    validation <- ifelse(missing, "inconnue", ifelse(passed, "oui", "non"))
    ects <- ifelse(
      missing, NA_integer_, ifelse(
        passed, 60L, sample(
          seq(0L, 54L, 6L),
          length(idx),
          TRUE
        )
      )
    )
    results[[y]] <- data.frame(
      inscription_id = ins$inscription_id, validation = validation, ects =
        as.integer(ects),
      date_jury = as.Date(
        paste0(
          substr(years[y], 6, 9),
          "-07-15"
        )
      )
    )
    enroll[[y]] <- ins
    # Pas de progression si le resultat administratif est inconnu.
    terminal_pass <- validation == "oui" & lev == formations$niveau_terminal[f]
    stays <- runif(length(idx)) <
      ifelse(validation == "oui", 0.94, 0.7)
    stays[terminal_pass] <- FALSE
    active[idx] <- stays
    advance <- validation == "oui" & !terminal_pass
    current_level[idx[advance]] <- lev[advance] + 1L
    reorient <- stays & !advance & runif(length(idx)) <
      0.12
    for (j in which(reorient)) {
      alternatives <- which(
        formations$cycle == formations$cycle[f[j]] & seq_len(5) !=
          f[j]
      )
      current_f[idx[j]] <- alternatives[sample.int(
        length(alternatives),
        1
      )]
      current_level[idx[j]] <- 1L
    }
  }
  inscriptions <- dplyr::bind_rows(enroll)
  resultats <- dplyr::bind_rows(results)
  b <- inscriptions |>
    dplyr::left_join(resultats, by = "inscription_id") |>
    dplyr::left_join(formations, by = "formation_id")
  terminal <- b$validation == "oui" & b$niveau == b$niveau_terminal
  diplomes <- data.frame(
    diplome_id = sprintf("D%05d", seq_len(sum(terminal))),
    inscription_id = b$inscription_id[terminal], date_diplome =
      b$date_jury[terminal],
    type_diplome = b$cycle[terminal]
  )
  # Classement : censure, reinscription (autre formation/passage/redoublement),
  # fin de formation diplomee, sortie documentee, puis inconnu.
  parcours <- b[, "inscription_id", drop = FALSE]
  parcours$statut <- "inconnue"
  parcours$inscription_suivante_id <- NA_character_
  parcours$source_information <- "absence_information"
  parcours$date_observation <- as.Date(config$observation_end)
  parcours$censure <- b$annee == tail(years, 1)
  lookup <- setNames(
    seq_len(nrow(b)),
    paste(b$etudiant_id, b$annee)
  )
  for (y in seq_len(
    length(years) -
      1L
  )) {
    ids <- which(b$annee == years[y])
    next_idx <- unname(lookup[paste(b$etudiant_id[ids], years[y + 1L])])
    has_next <- !is.na(next_idx)
    at <- ids[has_next]
    nxt <- next_idx[has_next]
    parcours$inscription_suivante_id[at] <- b$inscription_id[nxt]
    parcours$statut[at] <- ifelse(
      b$formation_id[at] != b$formation_id[nxt], "reorientation",
      ifelse(b$niveau[nxt] > b$niveau[at], "passage", "redoublement")
    )
    parcours$source_information[at] <- "inscriptions"
    end <- ids[!has_next & terminal[ids]]
    parcours$statut[end] <- "fin_formation_diplomee"
    parcours$source_information[end] <- "diplome"
    absent <- ids[!has_next & !terminal[ids]]
    observed <- absent[runif(length(absent)) <
                         sim$exit_documented_probability]
    parcours$statut[observed] <- "sortie_observee"
    parcours$source_information[observed] <- "suivi_fictif_explicite"
    parcours$date_observation[ids] <- as.Date(
      paste0(
        substr(years[y + 1L], 1, 4),
        "-11-30"
      )
    )
  }
  parcours$statut[parcours$censure] <- "censuree"
  parcours$source_information[parcours$censure] <- "fenetre_close"
  f <- match(inscriptions$formation_id, formations$formation_id)
  student_idx <- match(inscriptions$etudiant_id, etudiants$etudiant_id)
  delivered <- runif(nrow(b)) <
    sim$delivery_probability
  responded <- delivered & runif(nrow(b)) <
    plogis(0.1 + sim$formation_response_offsets[f] - 0.2 *
             boursier[student_idx])
  satisfaction <- sample(
    1:5, nrow(b),
    TRUE, c(0.04, 0.08, 0.17, 0.4, 0.31)
  )
  motive <- ifelse(!delivered, "non_sollicite", ifelse(!responded,
                                                       "non_reponse", "avis"))
  u <- runif(nrow(b))
  motive[responded & u < 0.05] <- "sans_avis"
  motive[responded & u >= 0.05 & u < 0.17] <- "item_manquant"
  satisfaction[motive != "avis"] <- NA_integer_
  # La reponse substantielle peut concerner l'item organisation seul.
  organisation <- ifelse(
    responded, sample(
      1:5, nrow(b),
      TRUE
    ),
    NA_integer_
  )
  evaluation <- data.frame(
    evaluation_id = paste0("Q_", b$inscription_id),
    inscription_id = b$inscription_id, vague = b$annee,
    sollicitation_delivree = delivered,
    consentement = responded, reponse = responded, satisfaction_1_5 =
      satisfaction,
    motif_satisfaction = motive, organisation_1_5 = organisation
  )
  maturity <- add_months(diplomes$date_diplome, config$outcome_horizon_months)
  eligible <- maturity <= as.Date(config$outcome_survey_cutoff)
  delivered <- eligible & runif(nrow(diplomes)) <
    0.94
  responded <- delivered & runif(nrow(diplomes)) <
    0.61
  situation <- rep(NA_character_, nrow(diplomes))
  situation[responded] <- sample(
    c("emploi", "recherche_emploi", "etudes", "inactif", "inconnue"),
    sum(responded),
    TRUE, c(0.57, 0.13, 0.24, 0.03, 0.03)
  )
  insertion <- data.frame(
    insertion_id = paste0("S_", diplomes$diplome_id),
    diplome_id = diplomes$diplome_id, vague = "six_mois", date_reference =
      maturity,
    date_enquete = as.Date(
      ifelse(
        eligible, as.character(maturity),
        NA_character_
      )
    ),
    eligible = eligible, sollicitation_delivree = delivered, reponse =
      responded,
    situation = situation
  )
  list(
    etudiants = etudiants, formations = formations, inscriptions = inscriptions,
    resultats = resultats, parcours = parcours, evaluation = evaluation,
    diplomes = diplomes,
    insertion = insertion
  )
}

data_dictionary <- function(tables) {
  # Le dictionnaire machine recense chaque variable, son type et ses modalites.
  dplyr::bind_rows(
    lapply(
      names(tables),
      function(n) {
        x <- tables[[n]]
        dplyr::bind_rows(
          lapply(
            names(x),
            function(v) {
              unique_values <- sort(
                unique(as.character(x[[v]])),
                na.last = NA
              )
              data.frame(
                table = n, variable = v, type = class(x[[v]])[1],
                cle_primaire = v == table_keys[[n]], nullable = anyNA(x[[v]]),
                modalites_ou_etendue = if (length(unique_values) <=
                                             12) {
                  paste(unique_values, collapse = " | ")
                } else {
                  paste(
                    head(unique_values, 1),
                    tail(unique_values, 1),
                    sep = " ... "
                  )
                },
                n_manquants = sum(is.na(x[[v]]))
              )
            }
          )
        )
      }
    )
  )
}

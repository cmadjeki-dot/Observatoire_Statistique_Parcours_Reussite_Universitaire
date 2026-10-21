validate_data <- function(tables, config) {
  state <- new.env(parent = emptyenv())
  state$issues <- list()
  flag <- function(table, bad, rule) {
    bad[is.na(bad)] <- TRUE
    if (any(bad)) {
      state$issues[[length(state$issues) + 1L]] <- data.frame(
        table = table, cle =
          as.character(tables[[table]][[table_keys[[table]]]][bad]),
        controle = rule, severite = "bloquante"
      )
    }
  }
  for (n in names(table_keys)) {
    x <- tables[[n]]
    key <- x[[table_keys[[n]]]]
    flag(
      n, is.na(key) |
        key == "", "cle_manquante"
    )
    flag(
      n, duplicated(key) |
        duplicated(key, fromLast = TRUE),
      "cle_dupliquee"
    )
  }
  ins <- tables$inscriptions
  res <- tables$resultats
  par <- tables$parcours
  ev <- tables$evaluation
  dip <- tables$diplomes
  emp <- tables$insertion
  fk <- function(child, field, parent, parent_key) {
    flag(
      child, !tables[[child]][[field]] %in% tables[[parent]][[parent_key]],
      paste0("reference_", field)
    )
  }
  fk("inscriptions", "etudiant_id", "etudiants", "etudiant_id")
  fk("inscriptions", "formation_id", "formations", "formation_id")
  for (child in c("resultats", "parcours", "evaluation",
                  "diplomes")) fk(child, "inscription_id", "inscriptions",
                                  "inscription_id")
  fk("insertion", "diplome_id", "diplomes", "diplome_id")
  flag("inscriptions", !ins$annee %in% config$academic_years, "annee_invalide")
  pair <- paste(ins$etudiant_id, ins$annee)
  flag(
    "inscriptions", duplicated(pair) |
      duplicated(pair, fromLast = TRUE),
    "double_inscription_principale"
  )
  form <- tables$formations[match(ins$formation_id,
                                  tables$formations$formation_id), ]
  flag(
    "inscriptions", is.na(ins$niveau) |
      ins$niveau < 1 | ins$niveau > form$niveau_terminal, "niveau_invalide"
  )
  flag(
    "resultats", !res$validation %in% c("oui", "non", "inconnue"),
    "validation_invalide"
  )
  flag(
    "resultats", !is.na(res$ects) &
      (res$ects < 0 | res$ects > 60), "ects_hors_domaine"
  )
  flag(
    "resultats", (res$validation == "oui" & (is.na(res$ects) |
                                               res$ects != 60)) |
      (res$validation == "non" & (is.na(res$ects) |
                                    res$ects >= 60)) |
      (res$validation == "inconnue" & !is.na(res$ects)),
    "ects_validation"
  )
  ry <- ins$annee[match(res$inscription_id, ins$inscription_id)]
  flag(
    "resultats", !is.na(ry) &
      (is.na(res$date_jury) |
        res$date_jury < as.Date(
          paste0(
            substr(ry, 6, 9),
            "-01-01"
          )
        ) |
        res$date_jury > as.Date(config$observation_end)),
    "chronologie_jury"
  )
  flag("inscriptions", !ins$inscription_id %in% res$inscription_id,
       "resultat_absent")
  flag("inscriptions", !ins$inscription_id %in% par$inscription_id,
       "parcours_absent")
  flag(
    "parcours", !par$statut %in% c(
      "passage", "redoublement", "reorientation", "sortie_observee",
      "fin_formation_diplomee",
      "inconnue", "censuree"
    ),
    "statut_invalide"
  )
  at <- match(par$inscription_id, ins$inscription_id)
  nx <- match(par$inscription_suivante_id, ins$inscription_id)
  has <- !is.na(par$inscription_suivante_id)
  flag(
    "parcours", has & is.na(nx),
    "reference_inscription_suivante"
  )
  censor <- ins$annee[at] == tail(config$academic_years, 1)
  flag(
    "parcours", !is.na(censor) &
      (par$censure != censor | (par$statut == "censuree") != censor),
    "censure_incoherente"
  )
  next_year <- match(ins$annee[nx], config$academic_years)
  current_year <- match(ins$annee[at], config$academic_years)
  flag(
    "parcours",
    has & !is.na(nx) & (ins$etudiant_id[at] != ins$etudiant_id[nx] |
                          next_year != current_year + 1L),
    "transition_identite_annee"
  )
  expected <- ifelse(
    ins$formation_id[at] != ins$formation_id[nx], "reorientation",
    ifelse(ins$niveau[nx] > ins$niveau[at], "passage", "redoublement")
  )
  flag(
    "parcours", has & !is.na(nx) &
      par$statut != expected, "transition_classement"
  )
  flag(
    "parcours", par$statut == "passage" &
      (res$validation[match(par$inscription_id, res$inscription_id)] !=
         "oui" | ins$niveau[nx] != ins$niveau[at] + 1L),
    "passage_sans_validation"
  )
  undocumented <- par$source_information != "suivi_fictif_explicite" |
    is.na(par$date_observation)
  flag(
    "parcours", par$statut == "sortie_observee" & undocumented,
    "sortie_non_documentee"
  )
  flag(
    "parcours", par$date_observation > as.Date(config$observation_end),
    "observation_future"
  )
  flag(
    "parcours", par$statut %in% c("passage", "redoublement", "reorientation") &
      !has, "transition_sans_cible"
  )
  flag(
    "evaluation", !is.na(ev$satisfaction_1_5) &
      !ev$satisfaction_1_5 %in% 1:5, "satisfaction_hors_domaine"
  )
  flag(
    "evaluation", ev$reponse & (!ev$sollicitation_delivree | !ev$consentement),
    "reponse_non_sollicitee"
  )
  flag(
    "evaluation", ev$reponse != (!is.na(ev$satisfaction_1_5) |
                                   !is.na(ev$organisation_1_5)),
    "reponse_substantielle"
  )
  evkey <- paste(ev$inscription_id, ev$vague)
  flag(
    "evaluation", duplicated(evkey) |
      duplicated(evkey, fromLast = TRUE),
    "doublon_vague"
  )
  di <- match(dip$inscription_id, ins$inscription_id)
  dr <- match(dip$inscription_id, res$inscription_id)
  df <- match(ins$formation_id[di], tables$formations$formation_id)
  flag(
    "diplomes", !is.na(di) &
      (ins$niveau[di] != tables$formations$niveau_terminal[df] |
         res$validation[dr] !=
           "oui" | dip$date_diplome < res$date_jury[dr]), "diplome_incoherent"
  )
  flag(
    "parcours", par$statut == "fin_formation_diplomee" &
      !par$inscription_id %in%
        dip$inscription_id, "fin_sans_diplome"
  )
  ed <- match(emp$diplome_id, dip$diplome_id)
  maturity <- add_months(dip$date_diplome, config$outcome_horizon_months)
  elig <- maturity[ed] <= as.Date(config$outcome_survey_cutoff)
  flag(
    "insertion", !is.na(ed) &
      (emp$eligible != elig | emp$date_reference != maturity[ed]),
    "maturite_incoherente"
  )
  flag(
    "insertion", (!emp$eligible & (emp$sollicitation_delivree | emp$reponse |
                                     !is.na(emp$date_enquete))) |
      (emp$reponse & !emp$sollicitation_delivree), "enquete_prematuree"
  )
  cutoff <- as.Date(config$outcome_survey_cutoff)
  invalid_date <- is.na(emp$date_enquete) |
    emp$date_enquete < emp$date_reference | emp$date_enquete > cutoff
  flag("insertion", emp$eligible & invalid_date, "chronologie_insertion")
  flag(
    "insertion", !is.na(emp$situation) &
      !emp$situation %in% c("emploi", "recherche_emploi", "etudes",
                            "inactif", "inconnue"),
    "situation_invalide"
  )
  ekey <- paste(emp$diplome_id, emp$vague)
  flag(
    "insertion", duplicated(ekey) |
      duplicated(ekey, fromLast = TRUE),
    "doublon_vague"
  )
  if (!length(state$issues)) {
    return(
      data.frame(
        table = character(), cle = character(), controle = character(),
        severite = character()
      )
    )
  }
  unique(dplyr::bind_rows(state$issues))
}

inject_anomalies <- function(tables) {
  raw <- tables
  state <- new.env(parent = emptyenv())
  state$reg <- list()
  log <- function(table, key, rule, before, after) {
    state$reg[[length(state$reg) + 1L]] <- data.frame(
      table = table, cle = key, controle = rule, valeur_avant =
        as.character(before),
      valeur_apres = as.character(after)
    )
  }
  for (n in names(tables)) {
    raw[[n]] <- rbind(raw[[n]], raw[[n]][1, , drop = FALSE])
    log(n, raw[[n]][[table_keys[[n]]]][1], "doublon_exact", "1 ligne",
        "2 lignes")
  }
  conflict <- raw$etudiants[2, , drop = FALSE]
  conflict$annee_naissance <- conflict$annee_naissance - 1L
  raw$etudiants <- rbind(raw$etudiants, conflict)
  log("etudiants", conflict$etudiant_id, "cle_dupliquee", "unique",
      "contradictoire")
  key <- raw$resultats$inscription_id[3]
  log("resultats", key, "ects_hors_domaine", raw$resultats$ects[3], 90)
  raw$resultats$ects[3] <- 90L
  orphan <- raw$resultats[4, , drop = FALSE]
  orphan$inscription_id <- "I_ORPHELINE"
  raw$resultats <- rbind(raw$resultats, orphan)
  log("resultats", orphan$inscription_id, "reference_inscription_id", NA,
      "ajout")
  log(
    "evaluation", raw$evaluation$evaluation_id[5], "satisfaction_hors_domaine",
    raw$evaluation$satisfaction_1_5[5], 9
  )
  raw$evaluation$satisfaction_1_5[5] <- 9L
  list(raw = raw, registre = dplyr::bind_rows(state$reg))
}

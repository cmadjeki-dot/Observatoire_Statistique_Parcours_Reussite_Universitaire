school_counts <- function(base, groups = c("annee", "formation_id")) {
  base |>
    dplyr::group_by(dplyr::across(dplyr::all_of(groups))) |>
    dplyr::summarise(
      inscrits = dplyr::n_distinct(.data$etudiant_id),
      validations = sum(.data$validation == "oui"),
      connus = sum(.data$validation %in% c("oui", "non")),
      inconnus = sum(.data$validation == "inconnue"),
      diplomes = sum(.data$validation == "oui" &
                       .data$niveau == .data$niveau_terminal),
      eligibles_diplome = sum(.data$niveau == .data$niveau_terminal),
      suivis = sum(!.data$censure),
      eligibles_passage = sum(!.data$censure &
                                .data$niveau < .data$niveau_terminal),
      passages = sum(.data$statut == "passage"),
      redoublements = sum(.data$statut == "redoublement"),
      reorientations = sum(.data$statut == "reorientation"),
      sorties_observees = sum(.data$statut == "sortie_observee"),
      situations_inconnues = sum(.data$statut == "inconnue"),
      fins_diplomees = sum(.data$statut == "fin_formation_diplomee"),
      censures = sum(.data$censure),
      .groups = "drop"
    )
}

school_metrics <- function(counts) {
  definitions <- list(
    effectif = c("inscrits", NA),
    validation_eligibles = c("validations", "inscrits"),
    couverture_resultats = c("connus", "inscrits"),
    validation_connus = c("validations", "connus"),
    validation_borne_basse = c("validations", "inscrits"),
    validation_borne_haute = c("validations_plus_inconnus", "inscrits"),
    diplomation_terminale = c("diplomes", "eligibles_diplome"),
    passage = c("passages", "eligibles_passage"),
    redoublement = c("redoublements", "suivis"),
    reorientation = c("reorientations", "suivis"),
    sortie_observee = c("sorties_observees", "suivis"),
    situation_inconnue = c("situations_inconnues", "suivis"),
    fin_formation_diplomee = c("fins_diplomees", "suivis")
  )
  counts$validations_plus_inconnus <- counts$validations + counts$inconnus
  ids <- intersect(
    c("annee", "formation_id", "niveau", "annee_entree_observee"),
    names(counts)
  )
  dplyr::bind_rows(
    lapply(
      names(definitions),
      function(ind) {
        pair <- definitions[[ind]]
        out <- counts[, ids, drop = FALSE]
        out$indicateur <- ind
        out$numerateur <- counts[[pair[1]]]
        out$denominateur <- if (is.na(pair[2])) {
          NA_real_
        } else {
          counts[[pair[2]]]
        }
        out$valeur <- if (ind == "effectif") {
          out$numerateur
        } else {
          ratio(out$numerateur, out$denominateur)
        }
        out$unite <- if (ind == "effectif") {
          "etudiants_annee"
        } else {
          "proportion"
        }
        out$motif_na <- ifelse(
          is.na(out$valeur),
          "denominateur_nul_ou_suivi_censure", NA_character_
        )
        out
      }
    )
  )
}

compute_indicators <- function(tables, config) {
  base <- analysis_base(tables)
  groupings <- list(
    annuel = "annee", formation = c("annee", "formation_id"),
    niveau = c("annee", "formation_id", "niveau"),
    cohorte = c("annee", "formation_id", "annee_entree_observee")
  )
  counts <- lapply(groupings, function(g) school_counts(base, g))
  metrics <- dplyr::bind_rows(
    lapply(
      names(counts),
      function(grain) {
        out <- school_metrics(counts[[grain]])
        out$grain <- grain
        out
      }
    )
  )
  metrics$date_cloture <- config$observation_end
  metrics$donnees <- "entierement_fictives"
  formation <- counts$formation |>
    dplyr::arrange(.data$formation_id, .data$annee) |>
    dplyr::group_by(.data$formation_id) |>
    dplyr::mutate(
      effectif_precedent = dplyr::lag(.data$inscrits),
      annee_precedente = dplyr::lag(.data$annee),
      evolution = ifelse(
        as.integer(substr(.data$annee, 1, 4)) -
          as.integer(substr(.data$annee_precedente, 1, 4)) ==
          1, ratio(.data$inscrits - .data$effectif_precedent,
                   .data$effectif_precedent),
        NA_real_
      )
    ) |>
    dplyr::ungroup()
  list(counts = counts, metrics = metrics, evolution = formation, base = base)
}

protect_fact <- function(x, threshold = 5L, population) {
  numbers <- names(x)[vapply(x, is.numeric, logical(1))]
  small <- function(v) {
    !is.na(v) &
      v > 0 & v < threshold
  }
  cell_sensitive <- vapply(
    seq_len(nrow(x)),
    function(i) {
      values <- as.numeric(unlist(x[i, numbers, drop = FALSE]))
      any(small(values)) ||
        any(small(x[[population]][i] - values)) ||
        x[[population]][i] < threshold
    }, logical(1)
  )
  # Protection volontairement conservatrice : toutes les formations de l'annee
  # sont masquees ensemble, y compris comptes et complements. Aucun total
  # annexe.
  years <- unique(x$annee[cell_sensitive])
  x$masque <- x$annee %in% years
  for (v in numbers) x[[v]][x$masque] <- NA_real_
  x
}

safe_sum <- function(x, variable) {
  if (!nrow(x) ||
        any(x$masque)) {
    return(NA_real_)
  }
  sum(x[[variable]])
}

filter_reference <- function(facts) {
  rows <- list()
  for (name in names(facts)) {
    fact <- facts[[name]]
    pairs <- switch(name,
      scolarite = list(
        validation = c("validations", "inscrits"),
        passage = c("passages", "eligibles_passage")
      ),
      evaluation = list(
        participation = c("repondants", "sollicites"),
        satisfaction = c("satisfaits", "avis")
      ),
      insertion = list(
        emploi = c("emploi", "situations_connues"),
        insertion_actifs = c("emploi", "actifs")
      )
    )
    for (year in unique(fact$annee)) {
      forms <- sort(unique(fact$formation_id[fact$annee == year]))
      selections <- c(
        list(Toutes = forms, Deux = head(forms, 2)),
        setNames(
          as.list(forms),
          forms
        )
      )
      for (sel in names(selections)) {
        sub <- fact[fact$annee == year &
                      fact$formation_id %in% selections[[sel]], ]
        for (metric in names(pairs)) {
          pair <- pairs[[metric]]
          n <- safe_sum(sub, pair[1])
          d <- safe_sum(sub, pair[2])
          rows[[length(rows) +
                  1L]] <- data.frame(
            fait = name, annee = year, filtre = sel, formations =
              paste(selections[[sel]], collapse = "|"),
            indicateur = metric, numerateur = n, denominateur = d,
            valeur_attendue_R = ratio(n, d),
            valeur_observee_PowerBI = NA_real_, statut =
              "A_VERIFIER_DANS_DESKTOP"
          )
        }
      }
    }
  }
  dplyr::bind_rows(rows)
}

export_powerbi <- function(tables, indicators, evaluation, insertion, config) {
  school <- indicators$counts$formation
  ev <- evaluation$counts[, c(
    "annee", "formation_id", "invites", "sollicites", "repondants", "avis",
    "satisfaits",
    "sans_avis", "items_manquants", "non_reponse"
  )]
  emp <- insertion[, c(
    "annee", "formation_id", "diplomes", "eligibles", "non_matures",
    "sollicites",
    "repondants", "situations_connues", "emploi", "recherche_emploi", "etudes",
    "inactif", "actifs", "non_reponse", "situations_inconnues"
  )]
  facts <- list(
    scolarite = protect_fact(school, config$disclosure_threshold, "inscrits"),
    evaluation = protect_fact(ev, config$disclosure_threshold, "invites"),
    insertion = protect_fact(emp, config$disclosure_threshold, "diplomes")
  )
  paths <- vapply(
    names(facts),
    function(n) {
      write_csv(
        facts[[n]], paste0("outputs/exports/powerbi/fait_", n, ".csv")
      )
    },
    character(1)
  )
  paths <- c(
    paths, write_csv(tables$formations,
                     "outputs/exports/powerbi/dim_formation.csv"),
    write_csv(
      data.frame(annee = config$academic_years, ordre =
                   seq_along(config$academic_years)),
      "outputs/exports/powerbi/dim_annee.csv"
    )
  )
  manifest <- data.frame(
    fichier = basename(paths),
    md5 = unname(tools::md5sum(paths)),
    donnees = "entierement_fictives", date_cloture = config$observation_end
  )
  paths <- c(paths, write_csv(manifest, "outputs/exports/powerbi/manifest.csv"))
  reference <- filter_reference(facts)
  write_csv(reference, "outputs/tables/recette_filtres_powerbi.csv")
  saveRDS(facts, "data/interim/exports_proteges.rds")
  list(paths = paths, facts = facts, reference = reference)
}

persist_pipeline <- function(
  synthetic, injected, prepared, indicators, evaluation, insertion, model,
  config
) {
  paths <- c(
    write_tables(synthetic, "data/synthetic"),
    write_tables(injected$raw, "data/raw"),
    write_tables(prepared$tables, "data/processed")
  )
  saveRDS(prepared, "data/interim/qualite.rds")
  saveRDS(indicators, "data/interim/indicateurs.rds")
  saveRDS(
    list(evaluation = evaluation, insertion = insertion),
    "data/interim/enquetes.rds"
  )
  saveRDS(model, "data/interim/modeles.rds")
  for (n in names(indicators$counts)) {
    paths <- c(
      paths, write_csv(indicators$counts[[n]],
                       paste0("outputs/tables/scolarite_", n, ".csv"))
    )
  }
  paths <- c(
    paths, write_csv(indicators$metrics, "outputs/tables/indicateurs.csv"),
    write_csv(indicators$evolution, "outputs/tables/evolution.csv"),
    write_csv(evaluation$counts, "outputs/tables/evaluation.csv"),
    write_csv(evaluation$profiles, "outputs/tables/non_reponse_profils.csv"),
    write_csv(insertion, "outputs/tables/insertion.csv"),
    write_csv(prepared$journal, "outputs/tables/journal_corrections.csv"),
    write_csv(prepared$volumes, "outputs/tables/volumes_qualite.csv"),
    write_csv(injected$registre, "data/reference/registre_injections.csv")
  )
  for (n in setdiff(
    names(model),
    "model"
  )) {
    paths <- c(paths, write_csv(model[[n]], paste0("outputs/tables/modele_",
                                                   n, ".csv")))
  }
  descriptive_analysis(indicators)
  export <- export_powerbi(prepared$tables, indicators, evaluation,
                           insertion, config)
  c(
    paths, export$paths, "outputs/figures/validation.png",
    "data/interim/qualite.rds",
    "data/interim/indicateurs.rds", "data/interim/enquetes.rds",
    "data/interim/modeles.rds"
  )
}

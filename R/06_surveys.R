survey_counts <- function(tables, groups = c("annee", "formation_id")) {
  ev <- tables$evaluation
  if (anyDuplicated(paste(ev$inscription_id, ev$vague))) {
    stop("Doublons de vague evaluation")
  }
  x <- ev |>
    dplyr::left_join(tables$inscriptions, by = "inscription_id",
                     relationship = "one-to-one") |>
    dplyr::left_join(tables$etudiants, by = "etudiant_id", relationship =
                       "many-to-one")
  result <- x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(groups))) |>
    dplyr::summarise(
      invites = dplyr::n(), sollicites = sum(.data$sollicitation_delivree),
      repondants = sum(.data$reponse & .data$sollicitation_delivree),
      avis = sum(
        !is.na(.data$satisfaction_1_5) &
          .data$reponse
      ),
      satisfaits = sum(.data$satisfaction_1_5 %in% 4:5 & .data$reponse),
      sans_avis = sum(.data$motif_satisfaction == "sans_avis"),
      items_manquants = sum(.data$motif_satisfaction == "item_manquant"),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      participation = ratio(.data$repondants, .data$sollicites),
      satisfaction = ratio(.data$satisfaits, .data$avis),
      non_reponse = .data$sollicites - .data$repondants, couverture_item =
        ratio(.data$avis, .data$repondants)
    )
  profiles <- x |>
    dplyr::filter(.data$sollicitation_delivree) |>
    dplyr::group_by(.data$annee, .data$formation_id, .data$type_bac,
                    .data$boursier) |>
    dplyr::summarise(
      sollicites = dplyr::n(), repondants = sum(.data$reponse),
      .groups = "drop"
    ) |>
    dplyr::mutate(participation = ratio(.data$repondants, .data$sollicites))
  list(counts = result, profiles = profiles)
}

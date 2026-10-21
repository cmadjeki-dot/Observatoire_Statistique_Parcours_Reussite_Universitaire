graduate_counts <- function(tables, groups = c("annee", "formation_id")) {
  emp <- tables$insertion
  known_situations <- c("emploi", "recherche_emploi", "etudes", "inactif")
  if (anyDuplicated(paste(emp$diplome_id, emp$vague))) {
    stop("Doublons de vague insertion")
  }
  x <- emp |>
    dplyr::left_join(tables$diplomes, by = "diplome_id", relationship =
                       "one-to-one") |>
    dplyr::left_join(tables$inscriptions, by = "inscription_id",
                     relationship = "one-to-one")
  x |>
    dplyr::group_by(dplyr::across(dplyr::all_of(groups))) |>
    dplyr::summarise(
      diplomes = dplyr::n(), eligibles = sum(.data$eligible),
      non_matures = sum(!.data$eligible),
      sollicites = sum(.data$eligible & .data$sollicitation_delivree),
      repondants = sum(.data$eligible & .data$reponse),
      situations_connues = sum(
        .data$eligible & .data$reponse &
          .data$situation %in% known_situations
      ),
      emploi = sum(.data$eligible & .data$reponse &
                     .data$situation %in% "emploi"),
      recherche_emploi = sum(.data$eligible & .data$reponse &
                               .data$situation %in% "recherche_emploi"),
      etudes = sum(.data$eligible & .data$reponse &
                     .data$situation %in% "etudes"),
      inactif = sum(.data$eligible & .data$reponse &
                      .data$situation %in% "inactif"),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      participation = ratio(.data$repondants, .data$sollicites),
      taux_emploi = ratio(.data$emploi, .data$situations_connues),
      actifs = .data$emploi + .data$recherche_emploi, insertion_actifs =
        ratio(.data$emploi, .data$actifs),
      non_reponse = .data$sollicites - .data$repondants,
      situations_inconnues = .data$repondants -
      .data$situations_connues
    )
}

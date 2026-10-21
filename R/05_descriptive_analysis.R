descriptive_analysis <- function(indicators) {
  x <- indicators$counts$formation
  x$taux <- ratio(x$validations, x$inscrits)
  p <- ggplot2::ggplot(x, ggplot2::aes(.data$annee, .data$taux, colour =
                                         .data$formation_id, group =
                                         .data$formation_id)) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::ylim(0, 1) +
    ggplot2::labs(
      title = "Validation annuelle / inscriptions eligibles", subtitle =
        "Donnees entierement fictives - aucune statistique UPEC",
      x = "Annee universitaire", y = "Proportion", colour = "Formation"
    ) +
    ggplot2::theme_minimal()
  dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave("outputs/figures/validation.png", p, width = 9, height =
                    5, dpi = 150)
  composition <- indicators$base |>
    dplyr::group_by(.data$annee, .data$formation_id, .data$type_bac,
                    .data$boursier) |>
    dplyr::summarise(effectif = dplyr::n(), .groups = "drop")
  write_csv(composition, "outputs/tables/composition_profils.csv")
  list(figure = "outputs/figures/validation.png", composition = composition)
}

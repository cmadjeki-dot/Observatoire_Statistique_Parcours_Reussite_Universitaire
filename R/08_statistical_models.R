model_analysis <- function(tables, config) {
  base <- analysis_base(tables) |>
    dplyr::arrange(.data$etudiant_id, .data$annee) |>
    dplyr::distinct(.data$etudiant_id, .keep_all = TRUE) |>
    dplyr::mutate(
      age = as.integer(substr(.data$annee, 1, 4)) -
        .data$annee_naissance, succes =
        ifelse(.data$validation == "inconnue", NA_integer_,
               as.integer(.data$validation == "oui")),
      inclus = !is.na(.data$succes) &
      !is.na(.data$type_bac) &
      !is.na(.data$boursier)
    )
  exclusions <- base |>
    dplyr::group_by(.data$formation_id, .data$annee, .data$validation,
                    .data$inclus) |>
    dplyr::summarise(effectif = dplyr::n(), .groups = "drop")
  x <- base[base$inclus, ]
  x$formation_id <- factor(x$formation_id)
  x$type_bac <- factor(x$type_bac)
  x$annee <- factor(x$annee)
  set.seed(config$seed + 6L)
  training <- sample.int(
    nrow(x),
    floor(0.7 * nrow(x))
  )
  train <- x[training, ]
  test <- x[-training, ]
  formula <- succes ~ formation_id + niveau + age + type_bac + boursier + annee
  fit <- stats::glm(formula, data = train, family = stats::binomial())
  se <- sqrt(diag(stats::vcov(fit)))
  matrix <- stats::model.matrix(fit)
  events_per_parameter <- min(
    sum(train$succes),
    sum(1 - train$succes)
  ) / ncol(matrix)
  if (!fit$converged || any(!is.finite(se)) ||
    any(
      abs(stats::coef(fit)) >
        15
    ) ||
    fit$rank != ncol(matrix) ||
    events_per_parameter < 10) {
    stop("Modele instable : analyse bloquee")
  }
  or <- data.frame(
    terme = names(stats::coef(fit)),
    coefficient = unname(stats::coef(fit)),
    erreur_standard = unname(se),
    odds_ratio = exp(stats::coef(fit)),
    borne_basse = exp(
      stats::coef(fit) -
        1.96 * se
    ),
    borne_haute = exp(
      stats::coef(fit) +
        1.96 * se
    )
  )
  p <- as.numeric(stats::predict(fit, newdata = test, type = "response"))
  y <- test$succes
  auc <- (sum(
    rank(p)[y ==
              1]
  ) -
    sum(y == 1) *
      (sum(y == 1) +
         1) / 2) / (sum(y == 1) *
                      sum(y == 0))
  test$probabilite <- p
  test$bin <- pmin(
    10L, ceiling(
      rank(p, ties.method = "first") / length(p) *
        10
    )
  )
  calibration <- test |>
    dplyr::group_by(.data$bin) |>
    dplyr::summarise(
      n = dplyr::n(), prediction = mean(.data$probabilite),
      observe = mean(.data$succes),
      .groups = "drop"
    )
  calibration_data <- data.frame(
    y = y, lp = qlogis(pmin(pmax(p, 1e-06), 1 - 1e-06))
  )
  cal <- stats::glm(
    y ~ lp, data = calibration_data, family = stats::binomial()
  )
  cols <- matrix[, -1, drop = FALSE]
  vif <- vapply(
    seq_len(ncol(cols)),
    function(j) {
      yj <- cols[, j]
      if (stats::var(yj) ==
            0) {
        return(Inf)
      }
      residual <- stats::lm.fit(
        cbind(1, cols[, -j, drop = FALSE]),
        yj
      )$residuals
      1 / (sum(residual^2) / sum((yj - mean(yj))^2))
    }, numeric(1)
  )
  sensitivity <- base[!is.na(base$succes), ]
  sensitivity$type_bac <- ifelse(
    is.na(sensitivity$type_bac),
    "inconnu", sensitivity$type_bac
  )
  sensitivity$boursier_cat <- ifelse(
    is.na(sensitivity$boursier),
    "inconnu", as.character(sensitivity$boursier)
  )
  fit_sensitivity <- stats::glm(
    succes ~ formation_id + niveau + age + type_bac + boursier_cat + annee,
    data = sensitivity,
    family = stats::binomial()
  )
  if (!fit_sensitivity$converged) {
    stop("Sensibilite non convergente")
  }
  sensitivity_or <- broom::tidy(fit_sensitivity, conf.int = FALSE,
                                exponentiate = TRUE)
  grid <- train[!duplicated(train$formation_id), ]
  grid$niveau <- 1L
  grid$age <- 21L
  grid$type_bac <- factor("general", levels = levels(x$type_bac))
  grid$boursier <- 0L
  grid$annee <- factor(config$academic_years[1], levels = levels(x$annee))
  grid$probabilite <- stats::predict(fit, newdata = grid, type = "response")
  comparison <- base |>
    dplyr::group_by(.data$annee_entree_observee, .data$formation_id,
                    .data$type_bac, .data$boursier) |>
    dplyr::summarise(
      n = dplyr::n(), connus = sum(!is.na(.data$succes)),
      validations = sum(.data$succes == 1, na.rm = TRUE),
      age_moyen = mean(.data$age),
      .groups = "drop"
    ) |>
    dplyr::mutate(validation_connus = ratio(.data$validations, .data$connus))
  diagnostics <- data.frame(
    n_premieres_inscriptions = nrow(base),
    n_inclus = nrow(x),
    n_exclus_resultat = sum(is.na(base$succes)),
    n_exclus_profil_parmi_resultats_connus = sum(
      !is.na(base$succes) &
        !base$inclus
    ),
    n_train = nrow(train),
    n_test = nrow(test),
    etudiants_communs = length(intersect(train$etudiant_id, test$etudiant_id)),
    convergence = fit$converged, evenements_par_parametre =
      events_per_parameter,
    probabilite_min = min(p),
    probabilite_max = max(p),
    vif_max = max(vif),
    brier = mean((p - y)^2),
    auc = auc, calibration_intercept = unname(stats::coef(cal)[1]),
    calibration_pente = unname(stats::coef(cal)[2])
  )
  stopifnot(diagnostics$etudiants_communs == 0)
  list(
    model = fit, odds_ratios = or, diagnostics = diagnostics, calibration =
      calibration,
    exclusions = exclusions, sensitivity = sensitivity_or, comparisons =
      comparison,
    predictions_profils = grid[, c(
      "formation_id", "niveau", "age", "type_bac", "boursier", "annee",
      "probabilite"
    )]
  )
}

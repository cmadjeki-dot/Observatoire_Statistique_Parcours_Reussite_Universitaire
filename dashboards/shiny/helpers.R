find_observatory_root <- function(start = getwd()) {
  root <- normalizePath(start, winslash = "/", mustWork = TRUE)
  while (!file.exists(file.path(root, ".here"))) {
    parent <- dirname(root)
    if (identical(root, parent)) stop("Racine du projet introuvable. Ouvrir Observatoire.Rproj.")
    root <- parent
  }
  root
}

load_dashboard_data <- function(root) {
  folder <- file.path(root, "outputs/exports/powerbi")
  files <- c(school = "fait_scolarite.csv", survey = "fait_evaluation.csv",
             employment = "fait_insertion.csv", formations = "dim_formation.csv")
  if (!all(file.exists(file.path(folder, files)))) {
    stop("Exports absents. Executer source('scripts/run_pipeline.R') depuis la racine.")
  }
  out <- lapply(files, function(file) as.data.frame(readr::read_csv(
    file.path(folder, file), show_col_types = FALSE, na = "",
    locale = readr::locale(encoding = "UTF-8"))))
  for (name in c("school", "survey", "employment")) {
    x <- out[[name]]
    if (any(c("etudiant_id", "inscription_id", "diplome_id") %in% names(x))) stop("Export individuel interdit")
    if (anyNA(x$masque) || !is.logical(x$masque)) stop("Drapeau de masquage invalide")
    if (anyDuplicated(paste(x$annee, x$formation_id))) stop("Grain formation-annee non unique")
    counts <- setdiff(names(x), c("annee", "formation_id", "masque"))
    if (!all(vapply(x[counts], is.numeric, logical(1)))) stop("Comptes non numeriques")
    if (any(x$masque) && !all(vapply(x[counts], function(v) all(is.na(v[x$masque])), logical(1)))) {
      stop("Un export masque contient encore des comptes")
    }
    if (any(vapply(x[counts], function(v) anyNA(v[!x$masque]), logical(1)))) stop("Compte disponible manquant")
  }
  out
}

dashboard_aggregate <- function(data, year, formation = "all") {
  rows <- data[data$annee == year & (formation == "all" | data$formation_id == formation), , drop = FALSE]
  if (!nrow(rows)) return(list(state = "absent"))
  if (any(rows$masque)) return(list(state = "masked"))
  fields <- setdiff(names(rows), c("annee", "formation_id", "masque"))
  c(list(state = "ok"), lapply(rows[fields], sum))
}

dashboard_rate <- function(x, numerator, denominator) {
  if (!identical(x$state, "ok") || is.null(x[[denominator]]) ||
      is.na(x[[denominator]]) || x[[denominator]] <= 0) return(NA_real_)
  x[[numerator]] / x[[denominator]]
}

dashboard_pct <- function(x) {
  if (length(x) != 1L || is.na(x)) return("Non calculable")
  paste0(formatC(100 * x, format = "f", digits = 1, decimal.mark = ","), " %")
}

dashboard_number <- function(x) {
  if (length(x) != 1L || is.na(x)) return("—")
  format(round(x), big.mark = " ", scientific = FALSE, trim = TRUE)
}

dashboard_status <- function(x) if (identical(x$state, "masked")) "Masqué" else "Non calculable"

dashboard_snapshot <- function(data, year, formation = "all") {
  school <- dashboard_aggregate(data$school, year, formation)
  survey <- dashboard_aggregate(data$survey, year, formation)
  employment <- dashboard_aggregate(data$employment, year, formation)
  previous_year <- paste0(as.integer(substr(year, 1, 4)) - 1L, "-", as.integer(substr(year, 6, 9)) - 1L)
  previous <- dashboard_aggregate(data$school, previous_year, formation)
  evolution <- if (identical(school$state, "ok") && identical(previous$state, "ok") && previous$inscrits > 0)
    (school$inscrits - previous$inscrits) / previous$inscrits else NA_real_
  # Les exports publies sont figes a la cloture du 30/09/2026.
  censored <- year == max(data$school$annee)
  list(school = school, survey = survey, employment = employment,
    evolution = evolution, censored = censored,
    success = dashboard_rate(school, "validations", "inscrits"),
    coverage = dashboard_rate(school, "connus", "inscrits"),
    satisfaction = dashboard_rate(survey, "satisfaits", "avis"),
    participation = dashboard_rate(survey, "repondants", "sollicites"),
    employment_rate = if (identical(employment$state, "ok") && employment$eligibles > 0)
      dashboard_rate(employment, "emploi", "situations_connues") else NA_real_)
}

dashboard_series <- function(data, formation, metric) {
  years <- sort(unique(data$school$annee))
  values <- vapply(years, function(year) {
    x <- dashboard_snapshot(data, year, formation)
    switch(metric, success = x$success, satisfaction = x$satisfaction,
      enrolment = if (identical(x$school$state, "ok")) x$school$inscrits else NA_real_,
      stop("Indicateur inconnu"))
  }, numeric(1))
  data.frame(annee = years, valeur = values)
}

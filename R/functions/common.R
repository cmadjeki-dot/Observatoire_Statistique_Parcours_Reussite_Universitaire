.data <- rlang::.data

project_path <- function(path = "") {
  root <- normalizePath(getwd(), winslash = "/")
  while (!file.exists(file.path(root, ".here"))) {
    parent <- dirname(root)
    if (identical(parent, root)) {
      stop("Racine du projet introuvable")
    }
    root <- parent
  }
  file.path(root, path)
}

read_config <- function(path = project_path("config/parameters.yml")) {
  yaml::yaml.load(
    paste(
      readLines(path, encoding = "UTF-8"),
      collapse = "\n"
    )
  )$project
}

ratio <- function(n, d) {
  ifelse(
    is.na(d) |
      d == 0, NA_real_, n / d
  )
}

add_months <- function(date, months = 6L) {
  date <- as.Date(date)
  # Les diplomes sont dates au 15 du mois : pas d'ambiguite de fin de mois.
  as.Date(
    vapply(
      seq_along(date),
      function(i) {
        format(
          seq(
            date[i],
            by = paste(months, "months"),
            length.out = 2
          )[2],
          "%Y-%m-%d"
        )
      }, character(1)
    )
  )
}

write_csv <- function(x, path) {
  dir.create(
    dirname(path),
    recursive = TRUE, showWarnings = FALSE
  )
  readr::write_csv(x, path, na = "")
  path
}

write_tables <- function(tables, folder) {
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  paths <- vapply(
    names(tables),
    function(n) write_csv(tables[[n]], file.path(folder, paste0(n, ".csv"))),
    character(1)
  )
  saveRDS(tables, file.path(folder, "tables.rds"))
  unname(c(paths, file.path(folder, "tables.rds")))
}

write_md <- function(lines, path) {
  dir.create(
    dirname(path),
    recursive = TRUE, showWarnings = FALSE
  )
  writeLines(
    enc2utf8(lines),
    path,
    useBytes = TRUE
  )
  path
}

table_keys <- c(
  etudiants = "etudiant_id", formations = "formation_id", inscriptions =
    "inscription_id",
  resultats = "inscription_id", parcours = "inscription_id", evaluation =
    "evaluation_id",
  diplomes = "diplome_id", insertion = "insertion_id"
)

analysis_base <- function(tables) {
  tables$inscriptions |>
    dplyr::left_join(tables$etudiants, by = "etudiant_id", relationship =
                       "many-to-one") |>
    dplyr::left_join(tables$formations, by = "formation_id", relationship =
                       "many-to-one") |>
    dplyr::left_join(tables$resultats, by = "inscription_id", relationship =
                       "one-to-one") |>
    dplyr::left_join(tables$parcours, by = "inscription_id", relationship =
                       "one-to-one")
}

phase_receipt <- function(phase, lines) {
  write_md(
    c(
      paste0("# Recette phase ", phase),
      "", "Donnees entierement fictives.", "", paste("Execution UTC :",
                                                     format(Sys.time(), tz =
                                                              "UTC", usetz =
                                                              TRUE)),
      "", lines
    ),
    paste0("docs/recettes/phase_", phase, ".md")
  )
}

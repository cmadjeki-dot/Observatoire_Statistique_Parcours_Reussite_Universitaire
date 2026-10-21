stopifnot(file.exists("renv/activate.R"), file.exists("renv.lock"))
source("scripts/activate_environment.R")
packages <- c("renv", "targets", "yaml", "readr", "dplyr", "tidyr",
              "ggplot2", "testthat", "knitr", "rmarkdown", "broom", "shiny", "lintr")
stopifnot(all(vapply(packages, requireNamespace, logical(1), quietly = TRUE)))
parameters <- yaml::yaml.load(paste(readLines("config/parameters.yml",
                                             encoding = "UTF-8"), collapse = "\n"))
stopifnot(parameters$project$n_students == 15000,
          length(parameters$project$academic_years) == 3)
for (path in list.files("scripts", pattern = "[.]R$", full.names = TRUE)) {
  parse(path)
}
renv::status()
cat("Vérification de l'initialisation terminée.\n")

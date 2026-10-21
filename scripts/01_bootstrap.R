# Installation explicite ; ne pas exécuter automatiquement à l'ouverture.
stopifnot(file.exists(".here"), file.exists("DESCRIPTION"))
options(repos = c(CRAN = "https://cloud.r-project.org"))
options(renv.config.consent = TRUE)
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
if (!file.exists("renv/activate.R")) renv::init(bare = TRUE, restart = FALSE)
renv::load(project = getwd())
renv::settings$snapshot.type("explicit")
packages <- c("targets", "yaml", "readr", "dplyr", "tidyr", "ggplot2",
              "testthat", "knitr", "rmarkdown", "broom", "shiny", "lintr")
renv::install(packages)
renv::snapshot(packages = c("renv", packages), prompt = FALSE)
source("scripts/00_environment_check.R")

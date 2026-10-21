source("scripts/activate_environment.R")
renv::install(c("formatR", "styler"))
renv::snapshot(prompt = FALSE)

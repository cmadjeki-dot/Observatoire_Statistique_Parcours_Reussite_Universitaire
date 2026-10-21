source("scripts/activate_environment.R")
if (!requireNamespace("shiny", quietly = TRUE)) renv::install("shiny")
renv::snapshot(prompt = FALSE)
cat("Shiny :", as.character(utils::packageVersion("shiny")), "\n")

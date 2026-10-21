# Depuis la racine : source("scripts/run_shiny.R")
source("scripts/activate_environment.R")
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
if (!requireNamespace("shiny", quietly = TRUE)) {
  stop("Shiny absent : executer source('scripts/setup_shiny.R') une fois.")
}
port <- as.integer(Sys.getenv("OBS_SHINY_PORT", "3839"))
shiny::runApp("dashboards/shiny", host = "127.0.0.1", port = port, launch.browser = interactive())

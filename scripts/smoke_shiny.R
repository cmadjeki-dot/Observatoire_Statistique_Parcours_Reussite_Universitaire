# Demarrage HTTP sur un port de recette distinct, puis arret du seul processus cree.
source("scripts/activate_environment.R")
out <- "outputs/validation_finale"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
run_smoke <- function() {
  port <- 3847L
  root <- normalizePath(".", winslash = "/")
  proc <- callr::r_bg(function(root, port) {
    setwd(root)
    if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
    shiny::runApp("dashboards/shiny", host = "127.0.0.1", port = port,
                  launch.browser = FALSE)
  }, args = list(root, port), libpath = .libPaths(), supervise = TRUE,
  stdout = file.path(out, "shiny_stdout.log"), stderr = file.path(out, "shiny_stderr.log"))
  on.exit(try(proc$kill_tree(), silent = TRUE), add = TRUE)
  address <- paste0("http://127.0.0.1:", port)
  page <- NULL
  for (i in seq_len(120L)) {
    if (!proc$is_alive()) stop("Shiny arrete avant le controle : voir shiny_stderr.log")
    page <- suppressWarnings(tryCatch(readLines(address, warn = FALSE), error = function(e) NULL))
    if (length(page) && any(grepl("Observatoire", page, fixed = TRUE))) break
    Sys.sleep(.25)
  }
  stopifnot(length(page) > 0L, any(grepl("Observatoire", page, fixed = TRUE)))
  writeLines(page, file.path(out, "shiny_smoke.html"), useBytes = TRUE)
  writeLines(sprintf('{"statut":"VALIDE","port":%d,"http":"accessible","arret":"processus_de_recette_uniquement"}', port),
             file.path(out, "shiny_smoke.json"))
  cat("Shiny accessible sur le port de recette", port, "; processus arrete en sortie.\n")
}
run_smoke()

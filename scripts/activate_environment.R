# Conserver l'isolation renv avec un sandbox propre au projet.
# Evite le verrou du sandbox global partage avec d'autres sessions R Windows.
stopifnot(file.exists(".here"), file.exists("renv/activate.R"))
if (!nzchar(Sys.getenv("RENV_PATHS_SANDBOX"))) {
  Sys.setenv(RENV_PATHS_SANDBOX = file.path(getwd(), "renv", "sandbox"))
}
local({
  current <- if ("renv" %in% loadedNamespaces()) renv::project() else NULL
  root <- normalizePath(getwd(), winslash = "/")
  active <- !is.null(current) && identical(
    normalizePath(current, winslash = "/", mustWork = FALSE), root
  )
  if (!active) source("renv/activate.R", local = FALSE)
})

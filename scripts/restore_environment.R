# Restauration des versions du lockfile ; ne pas remplacer par un snapshot.
stopifnot(file.exists(".here"), file.exists("renv.lock"))
source("scripts/activate_environment.R")
renv::restore(prompt = FALSE)
renv::status()

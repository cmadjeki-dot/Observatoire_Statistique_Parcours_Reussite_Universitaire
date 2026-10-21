# Installation explicite de l'outil d'audit demande ; aucune mise a jour globale.
source("scripts/activate_environment.R")
renv::install("lintr")
renv::snapshot(prompt = FALSE)

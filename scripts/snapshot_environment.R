# A utiliser seulement apres une modification volontaire des dependances.
source("scripts/activate_environment.R")
renv::snapshot(prompt = FALSE)
stopifnot(isTRUE(renv::status()$synchronized))

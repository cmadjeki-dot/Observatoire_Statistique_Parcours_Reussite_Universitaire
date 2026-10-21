source("scripts/activate_environment.R")
for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
               list.files("R", "[.]R$", full.names = TRUE))) source(path, encoding = "UTF-8")
testthat::test_dir("tests/testthat", stop_on_failure = TRUE)

source("scripts/activate_environment.R")
source("R/functions/common.R", encoding = "UTF-8")
testthat::test_file("tests/testthat/test-shiny.R", stop_on_failure = TRUE)

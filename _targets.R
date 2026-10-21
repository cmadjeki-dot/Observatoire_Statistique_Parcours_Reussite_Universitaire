library(targets)
for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
               list.files("R", "[.]R$", full.names = TRUE))) source(path, encoding = "UTF-8")
tar_option_set(packages = c("dplyr", "yaml", "ggplot2", "readr", "broom"), seed = 20261021L)
list(
  tar_target(config_file, "config/parameters.yml", format = "file"),
  tar_target(config, read_config(config_file)),
  tar_target(synthetic, {
    x <- generate_data(config)
    stopifnot(nrow(validate_data(x, config)) == 0L)
    x
  }),
  tar_target(injected, inject_anomalies(synthetic)),
  tar_target(prepared, prepare_data(injected$raw, config)),
  tar_target(indicators, compute_indicators(prepared$tables, config)),
  tar_target(evaluation, survey_counts(prepared$tables)),
  tar_target(insertion, graduate_counts(prepared$tables)),
  tar_target(model, model_analysis(prepared$tables, config)),
  tar_target(artifacts, persist_pipeline(synthetic, injected, prepared, indicators,
    evaluation, insertion, model, config), format = "file")
)

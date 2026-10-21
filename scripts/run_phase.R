source("scripts/activate_environment.R")
for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
               list.files("R", "[.]R$", full.names = TRUE))) source(path, encoding = "UTF-8")
run_config <- read_config()
args <- commandArgs(trailingOnly = TRUE)
phase <- if (length(args)) as.integer(args[1]) else 2L
if (phase > 2L && !file.exists(paste0("docs/recettes/phase_", phase - 1L, ".md"))) {
  stop("Recette de la phase precedente absente")
}
if (phase == 2L) {
  tables <- generate_data(run_config)
  stopifnot(identical(tables, generate_data(run_config)))
  issues <- validate_data(tables, run_config)
  if (nrow(issues)) { print(issues); stop("Reference synthetique invalide") }
  stopifnot(nrow(tables$etudiants) == run_config$n_students,
            length(unique(tables$inscriptions$etudiant_id)) == run_config$n_students)
  write_tables(tables, "data/synthetic")
  write_csv(data_dictionary(tables), "docs/dictionnaire_variables.csv")
  volumes <- data.frame(table = names(tables), lignes = vapply(tables, nrow, integer(1)))
  write_csv(volumes, "outputs/tables/volumes_synthetiques.csv")
  phase_receipt(2, c("Generation executee deux fois : objets strictement identiques.",
    "Huit tables controlees : aucune violation bloquante.",
    paste(volumes$table, volumes$lignes, sep = " : ")))
} else if (phase == 3L) {
  source_tables <- readRDS("data/synthetic/tables.rds")
  injected <- inject_anomalies(source_tables)
  write_tables(injected$raw, "data/raw")
  write_csv(injected$registre, "data/reference/registre_injections.csv")
  detected <- validate_data(injected$raw, run_config)
  prepared <- prepare_data(injected$raw, run_config)
  write_tables(prepared$tables, "data/processed")
  saveRDS(prepared, "data/interim/qualite.rds")
  write_csv(detected, "outputs/tables/anomalies_detectees.csv")
  write_csv(prepared$journal, "outputs/tables/journal_corrections.csv")
  write_csv(prepared$quarantine, "outputs/tables/quarantaine.csv")
  write_csv(prepared$volumes, "outputs/tables/volumes_qualite.csv")
  proof <- injected$registre
  proof$detectee <- vapply(seq_len(nrow(proof)), function(i) {
    if (proof$controle[i] == "doublon_exact") return(any(prepared$journal$table == proof$table[i] &
      prepared$journal$cle == proof$cle[i] & prepared$journal$controle == "doublon_exact"))
    any(detected$table == proof$table[i] & detected$cle == proof$cle[i] & detected$controle == proof$controle[i])
  }, logical(1))
  write_csv(proof, "outputs/tables/recette_injections.csv")
  stopifnot(all(proof$detectee), nrow(validate_data(prepared$tables, run_config)) == 0)
  testthat::test_file("tests/testthat/test-quality.R", stop_on_failure = TRUE)
  phase_receipt(3, c(paste(nrow(proof), "injections detectees sur", nrow(proof)),
    paste(nrow(prepared$journal), "operations journalisees ; conflits et dependances en quarantaine."),
    "Tests qualite executes ; aucune violation bloquante dans les tables preparees.",
    "La correction ne consulte pas le registre des injections."))
} else {
  run_later_phase(phase, run_config)
}
cat("Phase", phase, "terminee.\n")

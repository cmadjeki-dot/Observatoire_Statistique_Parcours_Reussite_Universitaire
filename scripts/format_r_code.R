# Mise en forme uniquement ; verifier ensuite les tests et les exports.
source("scripts/activate_environment.R")
styler::cache_deactivate()
for (path in list.files("R", "[.]R$", full.names = TRUE, recursive = TRUE)) {
  formatR::tidy_source(source = path, file = path, width.cutoff = 80L,
                       arrow = FALSE, blank = TRUE, comment = TRUE,
                       indent = 2L, args.newline = TRUE)
}
styler::style_dir("R", recursive = TRUE)
source("scripts/fix_r_layout.R")

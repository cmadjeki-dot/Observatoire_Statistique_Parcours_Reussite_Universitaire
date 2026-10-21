prepare_data <- function(raw, config) {
  x <- raw
  state <- new.env(parent = emptyenv())
  state$journal <- list()
  state$quarantine <- list()
  record <- function(n, rows, rule, status) {
    if (!nrow(rows)) {
      return(invisible(NULL))
    }
    state$journal[[length(state$journal) + 1L]] <- data.frame(
      table = n, cle = as.character(rows[[table_keys[[n]]]]),
      controle = rule, valeur_avant = vapply(
        seq_len(nrow(rows)),
        function(i) {
          paste(
            names(rows),
            as.character(unlist(rows[i, ], use.names = FALSE)),
            sep = "=", collapse = ";"
          )
        },
        character(1)
      ),
      valeur_apres = NA_character_, statut = status,
      motif = if (status == "deduplication") {
        "Lignes strictement identiques"
      } else {
        "Conflit ou incoherence non reparable sans source"
      }
    )
    if (status != "deduplication") {
      state$quarantine[[length(state$quarantine) + 1L]] <- data.frame(
        table = n, cle = as.character(rows[[table_keys[[n]]]]),
        controle = rule
      )
    }
  }
  for (n in names(x)) {
    dup <- duplicated(x[[n]])
    record(n, x[[n]][dup, , drop = FALSE], "doublon_exact", "deduplication")
    x[[n]] <- x[[n]][!dup, , drop = FALSE]
  }
  for (iteration in 1:20) {
    issues <- validate_data(x, config)
    if (!nrow(issues)) {
      break
    }
    for (n in unique(issues$table)) {
      bad <- x[[n]][[table_keys[[n]]]] %in% issues$cle[issues$table == n]
      record(
        n, x[[n]][bad, , drop = FALSE], paste(
          unique(issues$controle[issues$table == n]),
          collapse = "|"
        ),
        "quarantaine"
      )
      x[[n]] <- x[[n]][!bad, , drop = FALSE]
    }
    # Si une inscription suivante est retiree, le suivi amont perd sa preuve.
    # La ligne amont et ses dependances seront mises en quarantaine au tour
    # suivant.
  }
  remaining <- validate_data(x, config)
  if (nrow(remaining)) {
    stop("Violations bloquantes apres preparation")
  }
  list(
    tables = x, journal = dplyr::bind_rows(state$journal),
    quarantine = dplyr::bind_rows(state$quarantine),
    controles = remaining, volumes = data.frame(
      table = names(x),
      brut = vapply(raw, nrow, integer(1)),
      prepare = vapply(x, nrow, integer(1))
    )
  )
}

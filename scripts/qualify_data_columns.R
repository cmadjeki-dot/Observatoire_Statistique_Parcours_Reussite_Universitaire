# Migration ciblee des symboles signales vers les pronoms de donnees explicites.
source("scripts/activate_environment.R")
for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE),
               list.files("R", "[.]R$", full.names = TRUE))) source(path)
lints <- lintr::lint_dir("R")
changes <- list()
for (item in lints) {
  if (item$type != "warning" || !grepl("no visible binding for global variable", item$message)) next
  name <- sub(".*global variable '([^']+)'.*", "\\1", item$message)
  file <- file.path("R", item$filename)
  pd <- utils::getParseData(parse(file, keep.source = TRUE))
  token <- pd[pd$line1 == item$line_number & pd$col1 == item$column_number & pd$text == name, ]
  stopifnot(nrow(token) == 1L)
  ancestors <- character()
  id <- token$parent
  descendants <- function(id) {
    children <- pd[pd$parent == id, ]
    c(children$id, unlist(lapply(children$id[!children$terminal], descendants)))
  }
  while (id != 0L) {
    children <- pd[pd$parent == id, ]
    opening <- children[children$text == "(" & children$terminal, ]
    if (nrow(opening)) {
      first <- children[order(children$line1, children$col1), ][1, ]
      symbols <- pd[pd$id %in% c(first$id, descendants(first$id)) & pd$token == "SYMBOL_FUNCTION_CALL", ]
      if (nrow(symbols)) ancestors <- c(ancestors, symbols$text[1])
    }
    id <- pd$parent[match(id, pd$id)]
  }
  selection <- any(ancestors %in% c("select", "across", "pivot_longer", "rename"))
  masking <- any(ancestors %in% c("summarise", "summarize", "mutate", "group_by", "filter", "arrange", "distinct", "aes", "count", "transmute"))
  if (!selection && !masking) stop("Symbole a examiner manuellement : ", file, ":", item$line_number, " ", name)
  replacement <- if (selection) paste0('"', name, '"') else paste0(".data$", name)
  changes[[length(changes) + 1L]] <- data.frame(file, line = item$line_number,
    column = item$column_number, name, replacement)
}
changes <- do.call(rbind, changes)
if (!is.null(changes)) {
  changes <- unique(changes)
  for (file in unique(changes$file)) {
    lines <- readLines(file, encoding = "UTF-8", warn = FALSE)
    items <- changes[changes$file == file, ]
    items <- items[order(items$line, items$column, decreasing = TRUE), ]
    for (i in seq_len(nrow(items))) {
      change <- items[i, ]
      line <- lines[change$line]
      stopifnot(substr(line, change$column, change$column + nchar(change$name) - 1L) == change$name)
      lines[change$line] <- paste0(substr(line, 1L, change$column - 1L), change$replacement,
        substring(line, change$column + nchar(change$name)))
    }
    writeLines(lines, file, useBytes = TRUE)
  }
}
cat(if (is.null(changes)) 0L else nrow(changes), "references de colonnes explicitees.\n")

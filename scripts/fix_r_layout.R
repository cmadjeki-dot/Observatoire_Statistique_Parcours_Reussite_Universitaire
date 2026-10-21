# Ajustement des retours a la ligne et de l'indentation, sans desactiver lintr.
source("scripts/activate_environment.R")
files <- list.files("R", "[.]R$", full.names = TRUE, recursive = TRUE)
wrap_file <- function(path) {
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  long <- which(nchar(lines, type = "width") > 80L)
  if (!length(long)) return(invisible(NULL))
  pd <- utils::getParseData(parse(path, keep.source = TRUE))
  for (i in rev(long)) {
    line <- lines[i]
    indent <- nchar(line) - nchar(sub("^ +", "", line))
    if (grepl("^ *#", line)) {
      prefix <- paste0(strrep(" ", indent), "# ")
      lines[i] <- paste(paste0(prefix, strwrap(sub("^ *# *", "", line), width = 80L - nchar(prefix))), collapse = "\n")
      next
    }
    tokens <- pd[pd$terminal & pd$line1 == i & pd$line2 == i, ]
    choices <- tokens[tokens$text %in% c(",", "+", "-", "*", "/", "&&", "||", "&", "|", "|>", "<-", "="), ]
    choices <- choices[choices$col2 <= 76L & choices$col2 > indent + 6L, ]
    if (nrow(choices)) {
      split <- max(choices$col2)
      lines[i] <- paste0(substr(line, 1L, split), "\n", strrep(" ", indent + 2L), sub("^ +", "", substring(line, split + 1L)))
      next
    }
    strings <- tokens[tokens$token == "STR_CONST" & nchar(tokens$text) > 45L, ]
    if (nrow(strings)) {
      token <- strings[1, ]
      value <- eval(parse(text = token$text), envir = baseenv())
      width <- max(20L, 70L - indent)
      starts <- seq.int(1L, nchar(value), by = width)
      parts <- vapply(starts, function(start) encodeString(substr(value, start, start + width - 1L), quote = '"'), character(1))
      replacement <- paste0("paste0(\n", paste0(strrep(" ", indent + 2L), parts, collapse = ",\n"), "\n", strrep(" ", indent), ")")
      lines[i] <- paste0(substr(line, 1L, token$col1 - 1L), replacement, substring(line, token$col2 + 1L))
    }
  }
  writeLines(lines, path, useBytes = TRUE)
}
for (iteration in seq_len(20L)) {
  for (path in files) wrap_file(path)
  for (path in c(list.files("R/functions", "[.]R$", full.names = TRUE), list.files("R", "[.]R$", full.names = TRUE))) source(path)
  lint <- lintr::lint_dir("R")
  style <- Filter(function(x) x$type == "style", lint)
  cat("Passe", iteration, ":", length(style), "observations de style\n")
  if (!length(style)) break
  indents <- Filter(function(x) x$linter == "indentation_linter", style)
  for (path in unique(vapply(indents, function(x) file.path("R", x$filename), character(1)))) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    for (item in indents) {
      if (file.path("R", item$filename) != path) next
      spaces <- as.integer(sub(".*should be ([0-9]+) spaces.*", "\\1", item$message))
      stopifnot(!is.na(spaces))
      lines[item$line_number] <- paste0(strrep(" ", spaces), sub("^ +", "", lines[item$line_number]))
    }
    writeLines(lines, path, useBytes = TRUE)
  }
}
if (length(style)) {
  print(style)
  stop("Observations de style restantes : revue manuelle necessaire")
}

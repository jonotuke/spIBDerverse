load_rds_data <- function(file) {
  g <- tryCatch(
    readr::read_rds(file),
    error = function(e) {
      message(stringr::str_glue("Cannot load {file}"))
      return(NULL)
    }
  )
  if (!methods::is(g, "igraph")) {
    message(stringr::str_glue("{file} does not contain an igraph object"))
    return(NULL)
  }
  g
}
# pacman::p_load(conflicted, tidyverse, targets)
# load_previous_data("~/Desktop/2026-04-06-network.rds") |> print()

#' Check IBD file
#'
#' @param file IBD TSV file
#'
#' @returns Message about whether TSV has correct columns
#'
#' @export
check_ibd_file <- function(file) {
  df <- file |>
    readr::read_tsv(show_col_types = FALSE) |>
    janitor::clean_names()
  missing <- setdiff(c("iid1", "iid2"), colnames(df))
  if (length(missing) == 0) {
    msg <- "All fine"
  } else {
    msg <- stringr::str_glue(
      "The column(s) {stringr::str_c(missing, collapse = ', ')} are missing"
    )
  }
  msg
}

#' Check meta file
#'
#' @param file IBD TSV meta file
#'
#' @returns Message about whether TSV has correct columns
#'
#' @export
check_meta_file <- function(file) {
  df <- file |>
    readr::read_tsv(show_col_types = FALSE) |>
    janitor::clean_names()
  missing <- setdiff(c("iid"), colnames(df))
  if (length(missing) == 0) {
    msg <- "All fine"
  } else {
    msg <- "The column iid is not in the META file. We will use Column 1 as the iid"
  }
  msg
}
check_files <- function(ibd, meta) {
  # Read in files
  ibd <- ibd |>
    readr::read_tsv(show_col_types = FALSE)
  meta <- meta |>
    readr::read_tsv(show_col_types = FALSE)
  # Set up msg
  msg <- ""
  # If iid no in nodes, then set to first col
  if ("iid" %notin% colnames(meta)) {
    colnames(meta)[1] <- "iid"
  }
  # Look for duplicated IDs
  duplicated <- meta$iid[duplicated(meta$iid)]
  if (length(duplicated) > 0) {
    duplicated <- stringr::str_c(duplicated, collapse = ", ")
    msg <- stringr::str_c(
      msg,
      stringr::str_glue(
        "ID(s) {duplicated} are duplicated. "
      ),
      collapse = ""
    )
  }
  if (
    all(
      c("iid1", "iid2") %in% colnames(ibd)
    )
  ) {
    edge_ids <- unique(c(ibd$iid1, ibd$iid2))
    missing <- setdiff(edge_ids, meta$iid)
    if (length(missing) > 0) {
      missing <- stringr::str_c(missing[1:3], collapse = ", ")
      msg <- stringr::str_c(
        msg,
        "The following IDs (only first 3 shown) are not in the meta file: ",
        missing,
        collapse = ""
      )
    }
  }
  # No errors, then return all is fine
  if (msg == "") {
    msg <- "All fine"
  }
  msg
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  check_files(
    "inst/extdata/example-ibd-data.tsv",
    "inst/extdata/example-meta-data.tsv"
  ) |>
    print()
}

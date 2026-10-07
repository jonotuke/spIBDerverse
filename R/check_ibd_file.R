#' Check IBD file
#'
#' @param file IBD TSV file
#'
#' @returns Message about whether TSV has correct columns
#'
#' @export
check_ibd_file <- function(file) {
  # Read in data
  df <- file |>
    readr::read_tsv(show_col_types = FALSE) |>
    janitor::clean_names()
  # Set up message
  msg <- ""
  # Check IID1 and IId2
  iid_missing <- setdiff(c("iid1", "iid2"), colnames(df))
  if (length(iid_missing) > 0) {
    iid_msg <- stringr::str_glue(
      "The column(s) {stringr::str_c(iid_missing, collapse = ', ')} are missing."
    )
    msg <- stringr::str_c(msg, iid_msg, collapse = "")
  }
  # Check if frac_gp1 and frac_gp2
  frac_missing <- setdiff(c("frac_gp1", "frac_gp2"), colnames(df))
  if (length(frac_missing) > 0) {
    frac_msg <- stringr::str_glue(
      "The column(s) {stringr::str_c(frac_missing, collapse = ', ')} are missing.
      You need the meta file to have a frac_gp column"
    )
    msg <- stringr::str_c(msg, frac_msg, collapse = "")
  }
  # No errors, then return all is fine
  if (msg == "") {
    msg <- "All fine"
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
    msg <- "The column iid is not in the META file. 
    We will use Column 1 as the iid"
  }
  msg
}
#' check IBD files
#'
#' @param ibd ibd file
#' @param meta meta file
#'
#' @returns messages about if the files are fine
#'
#' @export
check_ibd_files <- function(ibd, meta) {
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
  if (any(c("frac_gp1", "frac_gp2") %notin% colnames(ibd))) {
    if ("frac_gp" %notin% colnames(meta)) {
      frac_msg <- "Missing frac_gp in both meta and ibd files"
      msg <- stringr::str_c(
        msg,
        frac_msg,
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
  check_ibd_files(
    "inst/extdata/example-ibd-data.tsv",
    "inst/extdata/meta-no-frac-gp.tsv"
  ) |>
    print()
}

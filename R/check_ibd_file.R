#' Check IBD file
#'
#' @param file IBD file (TSV or CSV, optionally compressed)
#'
#' @returns Message about whether the file has the correct columns
#'
#' @export
check_ibd_file <- function(file) {
  # Read in data
  df <- read_for_check(file, clean = TRUE)
  if (is.null(df)) {
    return("Cannot read the IBD file. Is it a valid TSV or CSV?")
  }
  # Set up message
  msg <- ""
  # Check IID1 and IId2
  iid_missing <- setdiff(c("iid1", "iid2"), colnames(df))
  if (length(iid_missing) > 0) {
    iid_msg <- stringr::str_glue(
      "The column(s) {stringr::str_c(iid_missing, collapse = ', ')} are missing. "
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
#' @param file IBD meta file (TSV or CSV, optionally compressed)
#'
#' @returns Message about whether the file has the correct columns
#'
#' @export
check_meta_file <- function(file) {
  # Column names are not cleaned, to match load_ibd_network()
  df <- read_for_check(file, clean = FALSE)
  if (is.null(df)) {
    return("Cannot read the META file. Is it a valid TSV or CSV?")
  }
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
  # Read in files, handling names the same way as load_ibd_network()
  ibd <- read_for_check(ibd, clean = TRUE)
  meta <- read_for_check(meta, clean = FALSE)
  if (is.null(ibd) || is.null(meta)) {
    return(
      "Cannot read the IBD and/or META file. Are they valid TSV or CSV files?"
    )
  }
  # Set up msg
  msg <- ""
  # If iid no in nodes, then set to first col
  if (!"iid" %in% colnames(meta)) {
    colnames(meta)[1] <- "iid"
  }
  # Look for duplicated IDs
  duplicated <- meta$iid[duplicated(meta$iid)]
  if (length(duplicated) > 0) {
    duplicated <- stringr::str_c(unique(duplicated), collapse = ", ")
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
      missing <- stringr::str_c(utils::head(missing, 3), collapse = ", ")
      msg <- stringr::str_c(
        msg,
        "The following IDs (only first 3 shown) are not in the meta file: ",
        missing,
        ". ",
        collapse = ""
      )
    }
  }
  if (any(!c("frac_gp1", "frac_gp2") %in% colnames(ibd))) {
    if (!"frac_gp" %in% colnames(meta)) {
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

#' Read a file for the check functions
#'
#' Uses the same reader as load_ibd_network(), so TSV, CSV and compressed
#' files are all handled. Returns NULL instead of erroring if the file can't
#' be read, so the Shiny status outputs show a message rather than crashing.
#'
#' @param path Path to the file.
#' @param clean Whether to apply janitor::clean_names().
#' @return A tibble, or NULL.
#' @noRd
read_for_check <- function(path, clean = FALSE) {
  tryCatch(
    {
      df <- read_delimited_file(path)
      if (clean) {
        df <- janitor::clean_names(df)
      }
      df
    },
    error = function(e) NULL
  )
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  check_ibd_files(
    "inst/extdata/example-ibd-data.csv",
    "inst/extdata/example-meta-data.csv"
  ) |>
    print()
}

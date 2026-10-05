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
    msg <- "File all fine"
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
    msg <- "File all fine"
  } else {
    msg <- "The column iid is not in the META file\nWe will use Column 1 as the iid"
  }
  msg
}
check_files <- function(ibd, meta) {
  # Read in files
  ibd <- ibd |>
    readr::read_tsv(show_col_types = FALSE)
  meta <- meta |>
    readr::read_tsv(show_col_types = FALSE)
  msg <- ""
  if ("iid" %notin% colnames(meta)) {
    colnames(meta)[1] <- "iid"
  }
  duplicated <- meta$iid[duplicated(meta$iid)]
  duplcated <- stringr::str_c(duplicated, collapse = ", ")
  if (length(duplicated) > 0) {
    msg <- stringr::str_c(
      msg,
      stringr::str_glue(
        "ID(s) {duplicated} are duplicated"
      ),
      collapse = ""
    )
  }
  if (msg == "") {
    msg <- "File all fine"
  }
  msg
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  check_ibd_file("inst/extdata/ibd-no-iid1-iid2.tsv") |> print()
  check_ibd_file("inst/extdata/example-ibd-data.tsv") |> print()
  check_meta_file("inst/extdata/example-meta-data.tsv") |> print()
  check_meta_file("inst/extdata/meta-no-iid.tsv") |> print()
  check_files(
    "inst/extdata/example-ibd-data.tsv",
    "inst/extdata/meta-duplicated-ids.tsv"
  ) |>
    print()
}

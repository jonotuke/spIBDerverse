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

#' load distance network
#'
#' @param node_file file with meta data
#' @param edge_file file with edge list
#'
#' @returns igraph object
#'
#' @export
load_dist_network <- function(
  node_file,
  edge_file
) {
  node_df <- tryCatch(
    readr::read_tsv(node_file),
    error = function(e) {
      message("Cannot load node file")
      return(NULL)
    }
  )
  if ("iid" %in% colnames(node_df)) {
    message("Using iid column as primary ID")
    node_df <- node_df |> dplyr::relocate(iid)
  } else {
    message("Using first column as primary ID")
    colnames(node_df)[1] <- "iid"
  }
  edge_df <- tryCatch(
    readr::read_tsv(edge_file),
    error = function(e) {
      message("Cannot load edge file")
      return(NULL)
    }
  )
  if ("iid1" %in% colnames(edge_df)) {
    message("Using iid1 as from column")
    edge_df <- edge_df |> dplyr::relocate(iid1)
  } else {
    message("Using first column as from column")
  }
  if ("iid2" %in% colnames(edge_df)) {
    message("Using iid2 as to column")
    edge_df <- edge_df |> dplyr::relocate(iid2, .after = 1)
  } else {
    message("Using second column as to column")
  }
  # GRAPH
  g <- tryCatch(
    igraph::graph_from_data_frame(
      edge_df,
      directed = FALSE,
      vertices = node_df
    ),
    error = function(e) {
      message("Cannot create igraph object")
      message(stringr::str_glue("Message is {e}"))
      return(NULL)
    }
  )
  if (is.null(g)) {
    return(g)
  }
  g <- g |> add_centrality_measures()
  g
}
#' loads some example data
#'
#' @description
#' For use in the data wizard module
#'
#'
#' @param example name of example data to upload
#'
#' @returns example network
#'
#' @export
#' @examples
#' load_example()
load_example <- function(example = "example_network") {
  data <- tryCatch(
    get(example, "package:spIBDerverse"),
    error = function(e) {
      message("That data does not exist\n")
      return(NULL)
    }
  )
  data
}
# fmt: skip
utils::globalVariables(c(
  "iid", "iid1", "iid2", "frac_gp", "frac_gp1", "frac_gp2",
  "n_ibd_8", "n_ibd_12", "n_ibd_16", "n_ibd_20", "sum_ibd_8", "wij"
))

#' Load an IBD network
#'
#' Reads pairwise IBD data and node metadata, keeps pairs that pass the
#' `frac_gp` quality filter and the IBD segment-count cutoffs, and builds an
#' undirected igraph object weighted by `sum_ibd_8`.
#'
#' Input files can be tab-separated (`.tsv`, `.tab`, `.txt`) or
#' comma-separated (`.csv`), optionally compressed (e.g. `.csv.gz`). The
#' format is chosen from the file extension; for any other extension the
#' delimiter is guessed from the file contents.
#'
#' @param ibd_file Path to a TSV or CSV file with pairwise IBD data. Must contain
#'   `iid1`, `iid2`, `n_ibd_8`, `n_ibd_12`, `n_ibd_16`, `n_ibd_20` and
#'   `sum_ibd_8` (after [janitor::clean_names()]).
#' @param meta_file Path to a TSV or CSV file with node metadata. If there is no
#'   `iid` column, the first column is used as the node ID. Must contain
#'   `frac_gp` if the IBD file lacks `frac_gp1` and `frac_gp2`.
#' @param ibd_co Numeric vector of length 4: minimum values of `n_ibd_8`,
#'   `n_ibd_12`, `n_ibd_16` and `n_ibd_20` required to define an edge.
#' @param frac_co Quality-control cutoff; both nodes of a pair must have
#'   `frac_gp >= frac_co`. Default is 0.7.
#' @param filter_on_meta If `TRUE`, only keep edges whose two nodes are both
#'   present in the metadata.
#'
#' @return An undirected igraph object with centrality measures added, or
#'   `NULL` (with a message) if the inputs cannot be read or are invalid.
#' @export
#' @examples
#' ibd_file <- fs::path_package(
#'   "extdata",
#'   "example-ibd-data.tsv",
#'   package = "spIBDerverse"
#' )
#' meta_file <- fs::path_package(
#'   "extdata",
#'   "example-meta-data.tsv",
#'   package = "spIBDerverse"
#' )
#' load_ibd_network(
#'   ibd_file,
#'   meta_file,
#'   ibd_co = c(0, 2, 1, 0)
#' )
load_ibd_network <- function(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.7,
  filter_on_meta = FALSE
) {
  if (!is.numeric(ibd_co) || length(ibd_co) != 4) {
    message("ibd_co must be a numeric vector of length 4")
    return(NULL)
  }

  # EDGES ----
  ibd <- tryCatch(
    ibd_file |>
      read_delimited_file() |>
      janitor::clean_names(),
    error = function(e) {
      message(stringr::str_glue("Cannot read in {ibd_file}"))
      NULL
    }
  )
  if (is.null(ibd)) {
    return(NULL)
  }

  required_ibd_cols <- c(
    "iid1",
    "iid2",
    "n_ibd_8",
    "n_ibd_12",
    "n_ibd_16",
    "n_ibd_20",
    "sum_ibd_8"
  )
  missing_ibd_cols <- setdiff(required_ibd_cols, colnames(ibd))
  if (length(missing_ibd_cols) > 0) {
    message(stringr::str_glue(
      "The IBD file is missing these columns: ",
      "{paste(missing_ibd_cols, collapse = ', ')}"
    ))
    return(NULL)
  }

  # NODES ----
  node_df <- tryCatch(
    read_delimited_file(meta_file),
    error = function(e) {
      message(stringr::str_glue("Cannot read in {meta_file}"))
      NULL
    }
  )
  if (is.null(node_df)) {
    return(NULL)
  }

  if (!"iid" %in% colnames(node_df)) {
    message(
      "The column iid is not in the META file\nWe will use Column 1 as the iid"
    )
    colnames(node_df)[1] <- "iid"
  }
  node_df <- node_df |> dplyr::relocate(iid)

  # FRAC_GP ----
  # If the IBD file doesn't already carry frac_gp for both nodes, take it from
  # the metadata.
  if (!all(c("frac_gp1", "frac_gp2") %in% colnames(ibd))) {
    if (!"frac_gp" %in% colnames(node_df)) {
      message("The metafile does not have a column called frac_gp")
      return(NULL)
    }
    frac_gp_df <- node_df |> dplyr::select(iid, frac_gp)
    ibd <- ibd |>
      # Drop a lone frac_gp1/frac_gp2 so the renames below don't collide
      dplyr::select(-dplyr::any_of(c("frac_gp1", "frac_gp2"))) |>
      dplyr::left_join(frac_gp_df, by = c("iid1" = "iid")) |>
      dplyr::rename(frac_gp1 = frac_gp) |>
      dplyr::left_join(frac_gp_df, by = c("iid2" = "iid")) |>
      dplyr::rename(frac_gp2 = frac_gp) |>
      dplyr::relocate(frac_gp1, frac_gp2, .after = iid2)
  }

  # EDGE SELECTION ----------------------------------------------------------
  # Edges are selected using the cutoffs on n_ibd_8/12/16/20; the edge weight
  # is sum_ibd_8. The edge list is built directly rather than going through an
  # adjacency matrix.
  edge_df <- ibd |>
    dplyr::filter(
      frac_gp1 >= frac_co,
      frac_gp2 >= frac_co,
      n_ibd_8 >= ibd_co[1],
      n_ibd_12 >= ibd_co[2],
      n_ibd_16 >= ibd_co[3],
      n_ibd_20 >= ibd_co[4]
    ) |>
    dplyr::mutate(wij = sum_ibd_8)

  if (filter_on_meta) {
    edge_df <- edge_df |>
      dplyr::filter(iid1 %in% node_df$iid, iid2 %in% node_df$iid)
  }

  # GRAPH -------------------------------------------------------------------
  g <- tryCatch(
    igraph::graph_from_data_frame(
      edge_df,
      directed = FALSE,
      vertices = node_df
    ),
    error = function(e) {
      message("Cannot create igraph object")
      message(stringr::str_glue("Message is: {conditionMessage(e)}"))
      NULL
    }
  )
  if (is.null(g)) {
    return(NULL)
  }

  g <- g |>
    add_centrality_measures() |>
    add_clustering()
}

#' Read a CSV or TSV file
#'
#' Picks the reader from the file extension (ignoring a compression suffix
#' such as `.gz`, `.bz2`, `.xz` or `.zip`). For unrecognised extensions,
#' readr guesses the delimiter from the file contents.
#'
#' @param path Path to the file.
#' @return A tibble.
#' @noRd
read_delimited_file <- function(path) {
  ext <- path |>
    tolower() |>
    sub(pattern = "\\.(gz|bz2|xz|zip)$", replacement = "") |>
    tools::file_ext()

  switch(
    ext,
    csv = readr::read_csv(path, show_col_types = FALSE),
    tsv = ,
    tab = ,
    txt = readr::read_tsv(path, show_col_types = FALSE),
    readr::read_delim(path, delim = NULL, show_col_types = FALSE)
  )
}
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

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

  if ("iid" %notin% colnames(node_df)) {
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
    if ("frac_gp" %notin% colnames(node_df)) {
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

  add_centrality_measures(g)
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

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  load_ibd_network(
    ibd_file = "inst/extdata/example-ibd-data.csv",
    meta_file = "inst/extdata/example-meta-data.csv"
  ) |>
    print()
}

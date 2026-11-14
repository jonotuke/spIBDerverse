# fmt: skip
utils::globalVariables(c(
  "iid", "iid1", "iid2", "frac_gp", "frac_gp1", "frac_gp2",
  "n_ibd_8", "n_ibd_12", "n_ibd_16", "n_ibd_20", "sum_ibd_8", "wij"
))
#' read file
#'
#' can read in CSV or TSV
#'
#' @param file filename
#'
#' @returns tibble
#'
#' @export
read_file <- function(file) {
  ext <- fs::path_ext(file)
  if (ext == "tsv") {
    readr::read_tsv(file, show_col_types = FALSE)
  } else if (ext == "csv") {
    readr::read_csv(file, show_col_types = FALSE)
  } else {
    rlang::abort("Unknown file type")
  }
}
#' adds frac_gp to ibd if needed, uses frac_gp in meta
#'
#' @param ibd ibd file
#' @param meta meta file
#'
#' @returns ibd with added frac_gp1 and frac_gp2
#'
#' @export
add_frac <- function(ibd, meta) {
  if (all(c("frac_gp1", "frac_gp2") %in% colnames(ibd))) {
    # rlang::inform("All ready have frac_gp1, frac_gp2, nothing to see here")
    return(ibd)
  }
  checkmate::assert_names(names(meta), must.include = "frac_gp")

  frac_gp_df <- meta |> dplyr::select(iid, frac_gp)
  ibd <- ibd |>
    # Drop a lone frac_gp1/frac_gp2 so the renames below don't collide
    dplyr::select(-dplyr::any_of(c("frac_gp1", "frac_gp2"))) |>
    dplyr::left_join(frac_gp_df, by = c("iid1" = "iid")) |>
    dplyr::rename(frac_gp1 = frac_gp) |>
    dplyr::left_join(frac_gp_df, by = c("iid2" = "iid")) |>
    dplyr::rename(frac_gp2 = frac_gp) |>
    dplyr::relocate(frac_gp1, frac_gp2, .after = iid2)
}
#' Load an IBD network
#'
#'
#' @param ibd_file ibd file
#' @param meta_file meta file
#' @param ibd_co cutoffs for edges
#' @param frac_co quality cutoff
#' @param crawl_length classifies nodes as seed, in crawl length of outside
#' of crawl length
#'
#' @return igraph object
#' @export
load_ibd <- function(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.7,
  crawl_length = 2L
) {
  checkmate::assert_numeric(ibd_co, len = 4)

  # EDGES ----
  ibd <- tryCatch(
    ibd_file |>
      read_file() |>
      janitor::clean_names(),
    error = function(e) {
      rlang::abort(stringr::str_glue("Cannot read in {ibd_file}"))
    }
  )

  required_ibd_cols <- c(
    "iid1",
    "iid2",
    "n_ibd_8",
    "n_ibd_12",
    "n_ibd_16",
    "n_ibd_20",
    "sum_ibd_8"
  )
  checkmate::assert_names(names(ibd), must.include = required_ibd_cols)

  # NODES ----
  node_df <- tryCatch(
    read_file(meta_file),
    error = function(e) {
      rlang::abort(stringr::str_glue("Cannot read in {meta_file}"))
    }
  )

  if (!"iid" %in% colnames(node_df)) {
    rlang::inform(
      "The column iid is not in the META file\nWe will use Column 1 as the iid"
    )
    colnames(node_df)[1] <- "iid"
  }
  node_df <- node_df |> dplyr::relocate(iid)

  # FRAC_GP ----
  ibd <- ibd |> add_frac(node_df)
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

  # Find missing nodes
  edge_nodes <- unique(c(edge_df$iid1, edge_df$iid2))
  seed_nodes <- node_df$iid
  missing <- edge_nodes[!edge_nodes %in% seed_nodes]

  missing_node_df <- tibble::tibble(
    iid = missing
  )
  fill_nodes <- dplyr::bind_rows(
    node_df,
    missing_node_df
  )
  # GRAPH -------------------------------------------------------------------
  g <- tryCatch(
    igraph::graph_from_data_frame(
      edge_df,
      directed = FALSE,
      vertices = fill_nodes
    ),
    error = function(e) {
      rlang::abort("Cannot make igraph")
    }
  )

  g <- g |>
    add_centrality_measures() |>
    add_clustering()
  seed_id <- names_to_ids(g, seed_nodes)
  g <- label_crawl(g, seed_id, k = crawl_length)
  g
}


if (sys.nframe() == 5) {
  load_ibd(
    ibd_file = "inst/extdata/crawl-ibd/crawl-ibd.tsv",
    meta_file = "inst/extdata/crawl-ibd/crawl-meta.tsv"
  ) |>
    plot_network(fill = ".crawl") |>
    print()
}

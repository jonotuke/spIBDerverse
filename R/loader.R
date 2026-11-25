#' read file
#'
#' can read in CSV or TSV
#'
#' @param file filename
#'
#' @returns tibble
#'
#' @noRd
read_file <- function(file) {
  ext <- tools::file_ext(file)
  if (ext == "tsv") {
    readr::read_tsv(file, show_col_types = FALSE)
  } else if (ext == "csv") {
    readr::read_csv(file, show_col_types = FALSE)
  } else {
    rlang::abort("Unknown file type")
  }
}
#' Load a network
#'
#'
#' @param edge_file edge file
#' @param node_file node file
#' @param crawl_length classifies nodes as seed, in crawl length of outside
#' of crawl length
#'
#' @return igraph object
#' @export
#' @examples
#' ibd_file <- system.file("extdata", "example-ibd/example-ibd-data.tsv", package = "spIBDerverse")
#' meta_file <- system.file("extdata", "example-ibd/example-meta-data.tsv", package = "spIBDerverse")
#'
#' g <- loader(ibd_file, meta_file)
#' g
loader <- function(
  edge_file,
  node_file,
  crawl_length = 2L
) {
  # EDGES ----
  checkmate::assert_file_exists(
    edge_file,
    access = "r",
    extension = c("csv", "tsv")
  )
  edge_df <-
    edge_file |>
    read_file() |>
    janitor::clean_names()

  # NODES ----
  checkmate::assert_file_exists(
    node_file,
    access = "r",
    extension = c("csv", "tsv")
  )
  node_df <-
    node_file |>
    read_file() |>
    janitor::clean_names()

  # Find missing nodes
  edge_nodes <- unique(c(edge_df[[1]], edge_df[[2]]))
  seed_nodes <- node_df[[1]]
  missing <- edge_nodes[!edge_nodes %in% seed_nodes]

  missing_node_df <- tibble::tibble(
    iid = missing
  )
  fill_nodes <- dplyr::bind_rows(
    node_df,
    missing_node_df
  )
  # GRAPH ----
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
    add_centrality() |>
    add_clustering()
  seed_id <- names_to_ids(g, seed_nodes)
  g <- crawler(g, seed_id, k = crawl_length)
  g
}

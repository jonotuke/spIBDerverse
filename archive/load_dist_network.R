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
# load_dist_network(
#   "~/Desktop/example_dist_node.tsv",
#   "~/Desktop/example_dist_edge.tsv"
# ) |>
#   print()

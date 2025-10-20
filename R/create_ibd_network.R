# fmt: skip
utils::globalVariables(
  c("frac_gp1", "frac_gp2", "n_ibd_8", "n_ibd_12", 
    "n_ibd_16", "n_ibd_20", "sum_ibd_8", "eij", 
    "iid1", "iid2", "wij")
)
#' create_ibd_network
#'
#' @param ibd_file CSV file with IBD data
#' @param meta_file CSV with node metadata
#' @param ibd_co vector of cutoffs for defining an edge
#' @param frac_co cutoff for quality control
#' @param only_connected boolean to remove unconnected nodes
#'
#' @return IBD network
#' @export
create_ibd_network <- function(
  ibd_file,
  meta_file = NULL,
  ibd_co,
  frac_co = 0.49,
  only_connected = TRUE
) {
  # EDGES
  ibd <- ibd_file |>
    readr::read_tsv() |>
    janitor::clean_names()
  # So we select edges eij based on cutoffs for n_ibd 8, 12, 16, 20
  # While the weight of edge is sum_ibd_8
  edge_df <- ibd |>
    dplyr::filter((frac_gp1 * frac_gp2) >= frac_co) |>
    dplyr::mutate(
      eij = as.numeric(
        ((n_ibd_8 >= ibd_co[1]) &
          (n_ibd_12 >= ibd_co[2]) &
          (n_ibd_16 >= ibd_co[3]) &
          (n_ibd_20 >= ibd_co[4]))
      ),
      wij = sum_ibd_8 * eij
    )
  # Ben creates an adjacency matrix to get the network, we will do it directly
  edge_df <- edge_df |>
    dplyr::filter(eij == 1) |>
    dplyr::select(iid1, iid2, wij)
  # NODES
  node_df <- readr::read_tsv(meta_file)
  # GRAPH
  g <- igraph::graph_from_data_frame(
    edge_df,
    directed = FALSE,
    vertices = node_df
  )
  igraph::V(g)$degree <- igraph::degree(g)
  # Simplify network
  if (only_connected) {
    g <- get_connected_graph(g)
  }
  g
}

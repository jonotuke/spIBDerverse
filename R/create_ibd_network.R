# fmt: skip
utils::globalVariables(
  c("frac_gp1", "frac_gp2", "frac_gp","n_ibd_8", "n_ibd_12", 
    "n_ibd_16", "n_ibd_20", "sum_ibd_8", "eij", 
    "iid1", "iid2", "iid","wij")
)
#' create_ibd_network
#'
#' @param ibd_file TSV file with IBD data
#' @param meta_file TSV with node metadata
#' @param ibd_co vector of cutoffs for defining an edge
#' @param frac_co cutoff for quality control - default is 0.49
#'
#' @return IBD network
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
#' create_ibd_network(
#'   ibd_file,
#'   meta_file,
#'   ibd_co = c(0, 2, 1, 0)
#' )
create_ibd_network <- function(
  ibd_file,
  meta_file,
  ibd_co,
  frac_co = 0.7
) {
  # EDGES
  ibd <- ibd_file |>
    readr::read_tsv(show_col_types = FALSE) |>
    janitor::clean_names()
  # NODES
  node_df <- readr::read_tsv(meta_file, show_col_types = FALSE)
  # Get frac_gp
  if (
    !all(
      "frac_gp1" %in% colnames(ibd),
      "frac_gp2" %in% colnames(ibd)
    )
  ) {
    frac_gp_df <- node_df |> dplyr::select(iid, frac_gp)
    ibd <- ibd |>
      dplyr::left_join(
        frac_gp_df,
        by = c("iid1" = "iid")
      ) |>
      dplyr::rename(frac_gp1 = frac_gp) |>
      dplyr::relocate(frac_gp1, .after = iid2) |>
      dplyr::left_join(
        frac_gp_df,
        by = c("iid2" = "iid")
      ) |>
      dplyr::rename(frac_gp2 = frac_gp) |>
      dplyr::relocate(frac_gp2, .after = frac_gp1)
  }
  # So we select edges eij based on cutoffs for n_ibd 8, 12, 16, 20
  # While the weight of edge is sum_ibd_8
  edge_df <- ibd |>
    dplyr::filter(
      frac_gp1 >= frac_co,
      frac_gp2 >= frac_co
    ) |>
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
  # GRAPH
  g <- igraph::graph_from_data_frame(
    edge_df,
    directed = FALSE,
    vertices = node_df
  )
  igraph::V(g)$degree <- igraph::degree(g)
  g
}
# ibd_file <- fs::path_package(
#   "extdata",
#   "example-ibd-data.tsv",
#   package = "spIBDerverse"
# )
# meta_file <- fs::path_package(
#   "extdata",
#   "example-meta-data.tsv",
#   package = "spIBDerverse"
# )
# create_ibd_network(
#   ibd_file,
#   meta_file,
#   ibd_co = c(0, 2, 1, 0)
# ) |>
#   print()

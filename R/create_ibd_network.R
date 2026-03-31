# fmt: skip
utils::globalVariables(
  c("frac_gp1", "frac_gp2", "frac_gp","n_ibd_8", "n_ibd_12", 
    "n_ibd_16", "n_ibd_20", "sum_ibd_8", "eij", 
    "iid1", "iid2", "iid","wij")
)
#' load_ibd_network
#'
#' @param ibd_file TSV file with IBD data
#' @param meta_file TSV with node metadata
#' @param ibd_co vector of cutoffs for defining an edge
#' @param frac_co cutoff for quality control - default is 0.49
#' @param filter_on_meta if true, only include edges that have nodes in meta df
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
  # EDGES
  ibd <- tryCatch(
    ibd_file |>
      readr::read_tsv(show_col_types = FALSE) |>
      janitor::clean_names(),
    error = function(e) {
      message(stringr::str_glue("Cannot read in {ibd_file}"))
      return(NULL)
    }
  )
  if (!all(c("iid1", "iid2") %in% colnames(ibd))) {
    message("The columns iid1 and iid2 are not in the IBD file")
    return(NULL)
  }
  # NODES
  node_df <- readr::read_tsv(meta_file, show_col_types = FALSE)
  if (!all(c("iid") %in% colnames(node_df))) {
    message("The column iid is not in the META file")
    return(NULL)
  }
  node_df <- node_df |> dplyr::relocate(iid)
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
    dplyr::select(-eij)
  # Filter edges based on node
  if (filter_on_meta) {
    node_iid <- node_df |> dplyr::pull(iid)
    edge_df <- edge_df |>
      dplyr::filter(iid1 %in% node_iid & iid2 %in% node_iid)
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
      return(NULL)
    }
  )
  igraph::V(g)$degree <- igraph::degree(g)
  igraph::V(g)$closeness = igraph::closeness(g)
  igraph::V(g)$betweenness = igraph::betweenness(g)
  igraph::V(g)$eigencentrality = igraph::eigen_centrality(g)$vector
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
# load_ibd_network(
#   ibd_file = ibd_file,
#   meta_file = meta_file
# ) |>
#   print()

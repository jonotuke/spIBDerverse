load_dist_network <- function(
  node_file,
  edge_file,
  dist_column = NULL,
  cutoff = NULL
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
}

# node_file <- fs::path_package(
#   package = "spIBDerverse",
#   "extdata/dist_network_nodes.tsv"
# )
# load_dist_network(node_file) |> print()

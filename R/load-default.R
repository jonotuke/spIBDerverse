filter_default_edges <- function(
  g,
  edge_attr = "none",
  edge_values = "none"
) {
  if (edge_attr == "none" | "none" %in% edge_values) {
    return(g)
  }
  checkmate::assert_class(g, "igraph")
  checkmate::assert_string(edge_attr)
  checkmate::assert_choice(edge_attr, igraph::edge_attr_names(g))

  x <- igraph::edge_attr(g, edge_attr)

  if (is.numeric(x)) {
    keep <- (x >= edge_values[1] & x <= edge_values[2])
  } else if (is.character(x) || is.factor(x) || is.logical(x)) {
    edge_values <- as.character(edge_values)
    unknown <- setdiff(edge_values, unique(as.character(x)))
    if (length(unknown) > 0) {
      rlang::warn(paste0(
        "Level(s) not found in `",
        edge_attr,
        "`: ",
        paste(unknown, collapse = ", ")
      ))
    }
    keep <- as.character(x) %in% edge_values
  } else {
    rlang::abort(paste0(
      "`",
      edge_attr,
      "` must be numeric, character, factor or logical, not ",
      class(x)[1],
      "."
    ))
  }

  keep <- !is.na(keep) & keep
  if (!any(keep)) {
    rlang::warn("No edges meet the criteria; graph will have no edges.")
  }
  g <- igraph::delete_edges(g, which(!keep))
  g <- g |> add_centrality() |> add_clustering()
  g
}
load_default <- function(node_file, edge_file) {
  # NODES ----
  checkmate::assert_file_exists(
    node_file,
    access = "r",
    extension = c("csv", "tsv")
  )
  node <-
    node_file |>
    read_file() |>
    janitor::clean_names()
  # EDGES ----
  checkmate::assert_file_exists(
    edge_file,
    access = "r",
    extension = c("csv", "tsv")
  )
  edge <-
    edge_file |>
    read_file() |>
    janitor::clean_names()
  # IGRAPH ----
  g <- tryCatch(
    igraph::graph_from_data_frame(
      edge,
      directed = FALSE,
      vertices = node
    ),
    error = function(e) {
      rlang::abort("Cannot make igraph", parent = e)
    }
  )
  g <- g |> add_centrality() |> add_clustering()
  g
}

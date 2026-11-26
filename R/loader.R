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
#' @param crawl_keep levels of crawl to keep
#' @param add_cluster add clusters to graph
#' @param add_central add centrality to graph
#' @param verbose adds progress bar
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
  crawl_length = 2L,
  crawl_keep = c("seed", "crawl", "outside"),
  add_cluster = TRUE,
  add_central = TRUE,
  verbose = FALSE
) {
  step <- if (verbose) cli::cli_progress_step else function(...) invisible()
  # EDGES ----
  checkmate::assert_file_exists(
    edge_file,
    access = "r",
    extension = c("csv", "tsv")
  )
  step("Reading edge file")
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
  step("Reading node file")
  node_df <-
    node_file |>
    read_file() |>
    janitor::clean_names()
  n_seed <- nrow(node_df)
  checkmate::assert_vector(node_df[[1]], unique = TRUE, any.missing = FALSE)

  # Get ids - first n_seed are those in the correct order
  # from the node file
  ids <- union(
    node_df[[1]],
    c(edge_df[[1]], edge_df[[2]])
  )
  n <- length(ids)
  checkmate::assert_set_equal(
    node_df[[1]],
    ids[1:n_seed],
    ordered = TRUE
  )

  # Get vector of from and to as integers
  from <- match(edge_df[[1]], ids)
  to <- match(edge_df[[2]], ids)

  # Create a graph
  step("Create graph")
  g <- igraph::make_graph(
    as.vector(rbind(from, to)),
    n = n,
    directed = FALSE
  )

  # Add given node info
  igraph::vertex_attr(g) <- c(
    list(name = ids),
    lapply(node_df[-1], \(x) x[seq_len(n)])
  )

  # ADD edge info
  igraph::edge_attr(g) <- as.list(edge_df[-(1:2)])

  # Add crawl based on node info
  step("Add crawl")
  within <- igraph::ego(
    g,
    order = 2,
    nodes = node_df[[1]],
    mode = "all"
  ) |>
    purrr::map(as.numeric) |>
    purrr::list_c() |>
    unique()

  igraph::V(g)$.crawl <- "outside"
  igraph::V(g)$.crawl[within] <- "crawl"
  igraph::V(g)$.crawl[1:n_seed] <- "seed"
  step("Filter crawl")
  g <- filter_crawl(g, levels = crawl_keep)

  # ADD centrality and clustering
  if (add_cluster) {
    step("Add cluster")
    g <- g |> add_clustering()
  }
  if (add_central) {
    step("Add centrality")
    g <- g |> add_centrality()
  }
  g
}

if (sys.nframe() == 5) {
  g <- loader(
    edge_file = "data-private/MIB_allIBD.tsv",
    node_file = "data-private/MIB_metadata.tsv",
    verbose = TRUE,
    crawl_keep = "seed"
  )
}

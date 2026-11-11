utils::globalVariables(
  c(
    "name",
    "degree"
  )
)
#' Get network summary
#'
#' @param g ibd network
#'
#' @return tibble with summary info on network
#' @export
#'
#' @examples
#' get_network_summary(example_network)
get_network_summary <- function(g) {
  checkmate::assert_class(g, "igraph")
  node_df <- igraph::as_data_frame(g, what = "vertices")
  node_df
  missing <-
    node_df |>
    dplyr::summarise(
      dplyr::across(
        dplyr::everything(),
        \(x) sum(is.na(x))
      )
    ) |>
    dplyr::select(-name, -dplyr::starts_with("."))
  tibble::tibble(
    measure = c(
      "Number of nodes",
      "Number of edges",
      "Number of unconnected nodes",
      stringr::str_glue("Number of nodes missing: {colnames(missing)}")
    ),
    value = c(
      igraph::vcount(g),
      igraph::ecount(g),
      sum(node_df$degree == 0),
      as.numeric(missing |> dplyr::slice(1))
    )
  )
}
#' get node attributes
#'
#' Remove centrality measures and can filter on cat or num. Attributes with
#' only one distinct value are dropped, as are categorical attributes with
#' more than `max_levels` distinct values.
#'
#' @param g network object
#' @param type type to return
#' @param inc_internals boolean to include internals - clusters and centrality
#' @param max_levels maximum number of distinct values a categorical attribute
#'   can have and still be returned. Defaults to `Inf` (no upper limit).
#' @param trim_levels boolean to trim nodes based on max_levels
#'
#' @returns list of attributes names
#'
#' @export
#' @examples
#' get_node_attributes(example_network)
#' get_node_attributes(example_network, "cat", max_levels = 10)
get_node_attributes <- function(
  g,
  type = "all",
  inc_internals = FALSE,
  max_levels = NULL,
  trim_levels = TRUE
) {
  if (!methods::is(g, "igraph")) {
    return(NULL)
  }
  if (is.null(max_levels)) {
    max_levels <- igraph::vcount(g)
  }
  node_df <- igraph::as_data_frame(g, what = "vertices")
  if (type == "cat") {
    vars <- node_df |>
      dplyr::select(dplyr::where(is.character)) |>
      colnames()
  } else if (type == "all") {
    vars <- node_df |>
      colnames()
  } else if (type == "num") {
    vars <- node_df |>
      dplyr::select(dplyr::where(is.numeric)) |>
      colnames()
  }
  if (!inc_internals) {
    vars <- vars |>
      purrr::discard(\(x) {
        stringr::str_detect(x, "^\\.")
      })
  }
  # drop attributes with a single level, and categorical ones with > max_levels
  n_levels <- purrr::map_int(node_df[vars], \(x) {
    dplyr::n_distinct(x, na.rm = TRUE)
  })
  is_cat <- purrr::map_lgl(
    node_df[vars],
    \(x) is.character(x) || is.factor(x)
  )
  keep <- n_levels > 1 & (!is_cat | n_levels < max_levels)
  if (trim_levels) {
    return(vars[keep])
  } else {
    return(vars)
  }
}
#' Get network node information
#'
#' @param g ibd network object
#'
#' @return tibble of node information
#' @export
#'
#' @examples
#' get_node_info(example_network)
get_node_info <- function(g) {
  igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble() |>
    pretty_col()
}

# DRIVER ----
if (sys.nframe() == 5) {
  get_node_attributes(
    example_network_2,
    type = "cat"
  ) |>
    print()
}

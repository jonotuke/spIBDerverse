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
  max_levels = 10
) {
  if (!methods::is(g, "igraph")) {
    return(NULL)
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
  keep <- n_levels > 1 & (!is_cat | n_levels <= max_levels)
  vars[keep]
}
if (sys.nframe() == 5) {
  get_node_attributes(example_network, "cat", max_levels = 10) |> print()
}

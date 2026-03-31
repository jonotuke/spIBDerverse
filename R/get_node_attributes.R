#' get node attributes
#'
#' Remove centrality measures and can filter on cat or num
#'
#' @param g network object
#' @param type type to return
#'
#' @returns list of attributes names
#'
#' @export
#' @examples
#' get_node_attributes(example_network)
get_node_attributes <- function(g, type = "all") {
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
  vars <- vars |>
    purrr::discard(\(x) {
      x %in% c("degree", "closeness", "betweenness", "eigencentrality")
    })
  vars
}
# get_node_attributes(example_network, "cat") |> print()

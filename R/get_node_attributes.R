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
      dplyr::select(-c(degree:eigencentrality)) |>
      colnames()
  } else if (type == "num") {
    vars <- node_df |>
      dplyr::select(dplyr::where(is.numeric)) |>
      dplyr::select(-c(degree:eigencentrality)) |>
      colnames()
  }
}
# get_node_attributes(example_network, "cat") |> print()

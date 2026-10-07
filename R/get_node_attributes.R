#' get node attributes
#'
#' Remove centrality measures and can filter on cat or num
#'
#' @param g network object
#' @param type type to return
#' @param exc_central boolean to remove centrality measures
#'
#' @returns list of attributes names
#'
#' @export
#' @examples
#' get_node_attributes(example_network)
get_node_attributes <- function(g, type = "all", exc_central = TRUE) {
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
  if (exc_central) {
    vars <- vars |>
      purrr::discard(\(x) {
        stringr::str_detect(x, "^\\.")
      })
  }
  vars
}
if (sys.nframe() == 5) {
  get_node_attributes(example_network, "num", exc_central = FALSE) |> print()
}

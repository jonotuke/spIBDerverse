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
    dplyr::select(-name, -degree)
  tibble::tibble(
    measure = c(
      "Number of nodes",
      "Number of unconnected nodes",
      stringr::str_glue("Number of nodes missing: {colnames(missing)}")
    ),
    value = c(
      igraph::vcount(g),
      sum(node_df$degree == 0),
      as.numeric(missing |> dplyr::slice(1))
    )
  )
}

#' Get network edge information
#'
#' @param g ibd network object
#'
#' @return tibble of node information
#' @export
#'
#' @examples
#' get_edge_info(example_network_2)
get_edge_info <- function(g) {
  igraph::as_data_frame(g, what = "edges") |>
    tibble::as_tibble() |>
    dplyr::mutate(
      dplyr::across(dplyr::starts_with("frac"), \(x) round(x, 4)),
      dplyr::across(
        dplyr::where(is.double) & !dplyr::starts_with("frac"),
        \(x) round(x, 2)
      )
    )
}

if (sys.nframe() == 5) {
  get_edge_info(example_network) |> print()
  BL <- readr::read_rds("~/Downloads/big.rds")
  get_edge_info(BL) |> print()
}

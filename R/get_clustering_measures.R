utils::globalVariables(
  c("sd")
)
#' get clustering measures
#'
#' @param g igraph object with clustering
#' @param pred pred to stratify on. If "none" returns
#' clustering for all nodes
#' @param cluster clustering measure
#'
#' @returns table of clustering
#'
#' @export
#' @examples
#' get_clustering_measures(example_network)
get_clustering_measures <- function(g, pred = "none", cluster = ".louvain") {
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()
  node_vars <- get_node_attributes(g)
  cluster_vars <- internal_df() |>
    dplyr::filter(type == "clustering") |>
    dplyr::pull(name)
  df <- df |>
    dplyr::select(dplyr::all_of(c(node_vars, cluster_vars)))
  if (pred != "none") {
    if (is.character(df[[pred]])) {
      df <- df |>
        dplyr::count(
          .data[[pred]],
          .data[[cluster]]
        ) |>
        tidyr::pivot_wider(
          names_from = tidyr::all_of(cluster),
          values_from = n,
          values_fill = 0
        )
    } else {
      df <- df |>
        dplyr::summarise(
          mean = mean(.data[[pred]]),
          sd = stats::sd(.data[[pred]]),
          n = dplyr::n(),
          .by = .data[[cluster]]
        ) |>
        dplyr::mutate(
          lwr = mean -
            stats::qt(0.025, n - 1, lower.tail = FALSE) * sd / sqrt(n),
          upr = mean +
            stats::qt(0.025, n - 1, lower.tail = FALSE) * sd / sqrt(n)
        )
    }
  }
  lookup <- stats::setNames(
    internal_df()$name,
    internal_df()$full_name
  )
  df <- df |>
    dplyr::rename(dplyr::any_of(lookup))
  df
}

if (sys.nframe() == 5) {
  get_clustering_measures(example_network, "lat") |> print()
}

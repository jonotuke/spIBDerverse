#' empirical test for centrality
#'
#' @param g igraph object
#' @param central node attribute that is centrality measure
#' @param preds preds for centrality
#' @param n_sims number of sims
#'
#' @returns
#'
#' @export
#' @examples
test_centrality_perm <- function(
  g,
  central = ".degree",
  preds = NULL,
  n_sims = 1000
) {
  if (is.null(preds)) {
    rlang::warn("No preds")
    class <- "no_preds"
    return(NULL)
  }
  # transform network into tibble
  df <- g |>
    igraph::as_data_frame(what = 'vertices') |>
    dplyr::as_tibble() |>
    dplyr::select(dplyr::all_of(c(central, preds))) |>
    tidyr::unite(
      col = 'predictor',
      dplyr::any_of(preds),
      remove = TRUE,
      sep = '\n'
    )

  form <- stats::reformulate(response = central, termlabels = "predictor")

  obs <- stats::kruskal.test(formula = form, data = df)$statistic

  # Permute values n times, and calculate the KW test stat
  # each time. Find how many simulated test stats are greater
  # than the observed value
  sims <- 1:n_sims |>
    purrr::map(\(x) {
      df |> dplyr::mutate(predictor = sample(predictor))
    }) |>
    purrr::list_rbind(names_to = "sim") |>
    tidyr::nest(data = -sim) |>
    dplyr::mutate(
      stat = purrr::map(data, \(x) stats::kruskal.test(form, x)$statistic)
    ) |>
    tidyr::unnest(stat)

  p_emp <- (sum(sims$stat >= obs) + 1) / (n_sims + 1)
}

if (sys.nframe() == 5) {
  test_centrality_perm(example_network, preds = c("genetic_sex", "site")) |>
    print()
}

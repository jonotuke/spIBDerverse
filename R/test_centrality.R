utils::globalVariables(
  c(".interaction", "sim", "stat", "predictor", "data")
)

#' Test centrality centralitys
#'
#' Tests using a linear model if any of the predss are significantly associated with
#' a given centrality measure
#'
#' @param g An igraph object.
#' @param centrality Name of the centrality measure to plot. Either a vertex
#'   attribute of `g` (e.g. `".degree"`) or one of the computed measures:
#'   `"closeness"`, `"betweenness"` or `"eigen_centrality"`.
#' @param preds predss to test
#'
#' @returns table indicating any significant predictors
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' test_centrality(example_network, ".degree", "genetic_sex")
test_centrality <- function(
  g,
  centrality = ".degree",
  preds = NULL
) {
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()
  if (is.null(preds)) {
    return(NULL)
  }

  missing_cols <- setdiff(c(centrality, preds), names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Unknown centrality or preds: ",
      stringr::str_c(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  form <- stats::reformulate(termlabels = preds, response = centrality)
  M <- stats::lm(form, data = df)
  stats::anova(M) |>
    broom::tidy() |>
    dplyr::filter(term != "Residuals") |>
    dplyr::select(term, p.value) |>
    dplyr::mutate(centrality = centrality)
}
#' Test centrality empirical
#'
#' Tests using empirical method
#'
#' @param g An igraph object.
#' @param centrality Name of the centrality measure to plot. Either a vertex
#'   attribute of `g` (e.g. `".degree"`) or one of the computed measures:
#'   `"closeness"`, `"betweenness"` or `"eigen_centrality"`.
#' @param preds preds to test
#' @param n_sims number of sims
#'
#' @returns table indicating any significant predictors
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' test_centrality_emp(example_network, ".degree", "genetic_sex")
test_centrality_emp <- function(
  g,
  centrality = ".degree",
  preds = NULL,
  n_sims = 100
) {
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()
  if (is.null(preds)) {
    return(NULL)
  }

  missing_cols <- setdiff(c(centrality, preds), names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Unknown centrality or preds: ",
      stringr::str_c(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  df <- df |>
    tidyr::unite(
      col = 'predictor',
      dplyr::any_of(preds),
      remove = TRUE,
      sep = '\n'
    )
  form <- stats::reformulate(response = centrality, termlabels = "predictor")

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
  tibble::tibble(
    predictor = stringr::str_c(preds, collapse = "|"),
    centrality = centrality,
    pv = p_emp
  )
}

#' test centralities
#'
#' @inheritParams test_centrality
#'
#' @returns table indicating any significant predictors
#'
#' @export
#' @examples
#' test_centralities(example_network, c(".degree", ".closeness"), "genetic_sex")
test_centralities <- function(g, centrality, preds) {
  centrality |>
    purrr::map(\(y) {
      test_centrality_emp(
        g,
        centrality = y,
        preds
      )
    }) |>
    purrr::list_rbind()
}

if (sys.nframe() == 5) {
  test_centrality_emp(
    example_network,
    preds = c("site", "genetic_sex")
  ) |>
    print()
  test_centralities(
    example_network,
    centrality = c(".degree", ".closeness"),
    preds = c("genetic_sex")
  ) |>
    print()
}

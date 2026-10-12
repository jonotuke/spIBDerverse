utils::globalVariables(".interaction")

#' Test centrality measures
#'
#' Tests using a linear model if any of the predictors are significantly associated with
#' a given centrality measure
#'
#' @param g An igraph object.
#' @param measure Name of the centrality measure to plot. Either a vertex
#'   attribute of `g` (e.g. `".degree"`) or one of the computed measures:
#'   `"closeness"`, `"betweenness"` or `"eigen_centrality"`.
#' @param predictor predictors to test
#'
#' @returns table indicating any significant predictors
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' test_centrality(example_network, ".degree", "genetic_sex")
test_centrality <- function(
  g,
  measure = ".degree",
  predictor = NULL
) {
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()
  if (is.null(predictor)) {
    return(NULL)
  }

  missing_cols <- setdiff(c(measure, predictor), names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Unknown measure or predictor: ",
      stringr::str_c(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  form <- stats::reformulate(termlabels = predictor, response = measure)
  M <- stats::lm(form, data = df)
  stats::anova(M) |>
    broom::tidy() |>
    dplyr::filter(term != "Residuals") |>
    dplyr::select(term, p.value)
}

if (sys.nframe() == 5) {
  test_centrality(
    example_network,
    ".closeness",
    c("site", "genetic_sex")
  ) |>
    print()
}

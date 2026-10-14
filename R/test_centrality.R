utils::globalVariables(".interaction")

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
      test_centrality(
        g,
        centrality = y,
        preds
      )
    }) |>
    purrr::list_rbind()
}

if (sys.nframe() == 5) {
  test_centralities(
    example_network,
    c(".degree", ".closeness"),
    c("site", "genetic_sex")
  ) |>
    print()
}

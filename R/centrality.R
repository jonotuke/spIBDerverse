utils::globalVariables(
  c(
    ".closeness",
    ".eigencentrality",
    "nodes",
    ".degree",
    "KW_pv",
    "dunn_pv_adj",
    "dunn_pv",
    "dunn",
    "z"
  )
)
utils::globalVariables(
  c(".interaction", "sim", "stat", "predictor", "data")
)
#' Adds centrality measures to an igraph object
#'
#' @param g igraph object
#'
#' @returns igraph with centrality measures of form .degree etc
#'
#' @export
#' @examples
#' add_centrality(example_network)
add_centrality <- function(g) {
  igraph::V(g)$.degree <- igraph::degree(g)
  igraph::V(g)$.closeness <- igraph::closeness(g)
  igraph::V(g)$.betweenness <- igraph::betweenness(g)
  igraph::V(g)$.eigencentrality <- igraph::eigen_centrality(g)$vector
  g
}
#' Get centrality measures
#'
#' @description
#' Gives a table of mean centrality measures
#' given a list of vertex attributes to stratify
#' on. If not list given then gives overall.
#'
#'
#' @param g igraph object
#' @param var character vector of attributes to stratify on
#'
#' @returns tibble of centrality measures
#'
#' @export
#' @examples
#' get_centrality_measures(example_network, c("site", "genetic_sex"))
get_centrality_measures <- function(g, var = NULL) {
  if (is.null(var)) {
    var <- "vertex_id"
  }
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::rownames_to_column(var = "vertex_id") |>
    tibble::as_tibble() |>
    dplyr::mutate(
      nodes = 1
    )
  df |>
    dplyr::group_by(
      dplyr::across(dplyr::any_of(var))
    ) |>
    dplyr::reframe(
      dplyr::across(
        c(dplyr::all_of(
          c(
            ".degree",
            ".closeness",
            ".betweenness",
            ".eigencentrality"
          )
        )),
        \(x) {
          mean(x, na.rm = TRUE)
        }
      ),
      dplyr::across(nodes, sum),
    ) |>
    dplyr::relocate(nodes, .before = .degree)
}
utils::globalVariables(
  c(".interaction", "value", "centrality")
)
#' Plot centrality measures
#'
#' Computes closeness, betweenness and eigenvector centrality for every vertex
#' of `g` and plots the chosen measure. Without `preds` a histogram of the
#' measure is drawn; with `preds` a boxplot is drawn for each combination of
#' the facet attributes, ordered by the median of the measure.
#'
#' @param g An igraph object.
#' @param centrality centrality measures
#' @param preds Preditors for centrality
#' @param rotate If `TRUE`, rotate the x-axis labels by 90 degrees.
#' @param pal palette to use
#' @param log_trans log scale on y-axis
#'
#' @returns A ggplot object: a histogram if `preds` is `NULL`, otherwise a
#'   boxplot.
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' plot_centrality(example_network)
#' plot_centrality(example_network, ".closeness", rotate = TRUE)
plot_centrality <- function(
  g,
  centrality = ".degree",
  preds = NULL,
  rotate = FALSE,
  pal = "default",
  log_trans = FALSE
) {
  # Convert g to df
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()

  # Check for centrality measures and preds in graph attributes
  missing_cols <- setdiff(c(centrality, preds), names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Unknown centrality or preds: ",
      stringr::str_c(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  df <- df |>
    tidyr::pivot_longer(
      tidyr::all_of(centrality),
      names_to = ".centrality"
    )
  if (is.null(preds)) {
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = value)
    ) +
      ggplot2::geom_histogram(col = "white", fill = "black") +
      ggplot2::facet_wrap(~.centrality, scales = "free", ncol = 2)
  } else {
    facet_label <- stringr::str_c(preds, collapse = "\n")

    df <- df |>
      dplyr::mutate(
        .interaction = interaction(df[preds], sep = "\n"),
        .interaction = forcats::fct_reorder(.interaction, value)
      )

    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .interaction, y = value, fill = .interaction)
    ) +
      ggplot2::geom_boxplot(show.legend = FALSE) +
      ggplot2::labs(x = facet_label, fill = facet_label) +
      pal_scale("fill", pal, "discrete")
    ggplot2::facet_wrap(~.centrality, scales = "free")
  }

  p <- p + ggplot2::theme_bw()

  if (rotate) {
    p <- p +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(
          angle = 90,
          hjust = 1,
          vjust = 0.5
        )
      )
  }

  if (log_trans) {
    p <- p + ggplot2::scale_y_log10()
  }

  p
}
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
#' @param min_alpha min alpha
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
  n_sims = 999,
  min_alpha = 0.01
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
      sep = '|'
    )

  # Decide on n_sims
  n_grp <- length(unique(df$predictor))
  k <- choose(n_grp, 2)
  n_sims <- max(k / min_alpha - 1, n_sims)

  form <- stats::reformulate(response = centrality, termlabels = "predictor")

  tests <- dunn_perm(
    df[[centrality]],
    df[["predictor"]],
    B = n_sims
  )

  tests[["dunn"]] <- tests[["dunn"]] |>
    dplyr::mutate(
      dunn_pv_adj = stats::p.adjust(dunn_pv, method = "holm")
    )
  KW_pv <- tests[["kw"]]$KW_pv
  tibble::tibble(
    predictor = stringr::str_c(preds, collapse = "|"),
    centrality = centrality,
    KW_pv = KW_pv,
    dunn = list(tests[["dunn"]])
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
#' Produces formated gt table
#' @noRd
get_centrality_gt <- function(cent_test) {
  cent_test |>
    tidyr::unnest(dunn) |>
    dplyr::mutate(
      centrality = stringr::str_glue(
        "{centrality} (KW p-value: {gt::vec_fmt_scientific(KW_pv, decimals = 2, output = 'html')})"
      )
    ) |>
    dplyr::group_by(centrality) |>
    dplyr::select(-KW_pv) |>
    gt::gt(process_md = TRUE) |>
    gt::tab_style_body(
      columns = dunn_pv_adj,
      style = gt::cell_fill(color = "lightblue"),
      fn = function(x) x <= 0.05
    ) |>
    gt::fmt_scientific(c(dunn_pv, dunn_pv_adj)) |>
    gt::fmt_number(z) |>
    gt::tab_style(
      style = list(
        gt::cell_fill(color = "lightblue"),
        gt::cell_text(weight = "bold")
      ),
      locations = gt::cells_row_groups()
    )
}

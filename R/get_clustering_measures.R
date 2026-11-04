utils::globalVariables(
  c("sd", "n", "prop", "label", "type", "name")
)

# Internal: long-format counts of nodes per predictor level x cluster.
# Shared by get_clustering_measures() and plot_clustering_confusion().
count_clusters_by_pred <- function(df, pred, cluster) {
  df |>
    dplyr::mutate(
      "{cluster}" := forcats::fct_relevel(
        as.character(.data[[cluster]]),
        \(lvls) stringr::str_sort(lvls, numeric = TRUE)
      ),
      "{pred}" := factor(.data[[pred]])
    ) |>
    dplyr::count(.data[[pred]], .data[[cluster]], .drop = FALSE)
}

# Internal: node + clustering attributes as a tibble.
clustering_vertex_df <- function(g) {
  node_vars <- get_node_attributes(g)
  cluster_vars <- internal_df() |>
    dplyr::filter(type == "clustering") |>
    dplyr::pull(name)
  igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble() |>
    dplyr::select(dplyr::all_of(c(node_vars, cluster_vars)))
}

# Internal: internal variable name -> display name (falls back to x).
pretty_var_name <- function(x) {
  idf <- internal_df()
  if (x %in% idf$name) idf$full_name[match(x, idf$name)] else x
}

#' get clustering measures
#'
#' @param g igraph object with clustering
#' @param pred pred to stratify on. If "none" returns
#' clustering for all nodes
#' @param cluster clustering measure
#'
#' @returns table of clustering
#'
#' @seealso [plot_clustering_confusion()] for a heatmap of the
#'   categorical-predictor table.
#' @export
#' @importFrom rlang := .data
#' @examples
#' get_clustering_measures(example_network)
get_clustering_measures <- function(g, pred = "none", cluster = ".louvain") {
  df <- clustering_vertex_df(g)
  if (pred != "none") {
    if (is.character(df[[pred]])) {
      df <- count_clusters_by_pred(df, pred, cluster) |>
        tidyr::pivot_wider(
          names_from = tidyr::all_of(cluster),
          values_from = n,
          values_fill = 0,
          names_sort = TRUE
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

#' Plot cluster membership against a categorical predictor
#'
#' @inheritParams get_clustering_measures
#' @param pred character node attribute to cross-tabulate against.
#' @param normalise one of `"none"` (raw counts), `"pred"` (proportion of
#'   each predictor level falling in each cluster) or `"cluster"`
#'   (composition of each cluster).
#' @param n_levels maximum number of levels
#' @param base_size size of text
#'
#' @returns a ggplot object, or `NULL` (invisibly) if `pred` or `cluster`
#'   has more than `n_levels` levels.
#' @export
#' @examples
#' plot_clustering_confusion(example_network_2, "Province")
plot_clustering_confusion <- function(
  g,
  pred,
  cluster = ".louvain",
  normalise = c("none", "pred", "cluster"),
  n_levels = 20,
  base_size = 14
) {
  normalise <- match.arg(normalise)
  df <- clustering_vertex_df(g)
  if (!is.character(df[[pred]]) && !is.factor(df[[pred]])) {
    rlang::abort(
      sprintf(
        "'%s' must be a categorical node attribute.",
        pretty_var_name(pred)
      ),
      class = "clustering_confusion_not_categorical",
      pred = pred
    )
  }

  counts <- count_clusters_by_pred(df, pred, cluster)

  n_pred <- nlevels(counts[[pred]])
  n_cluster <- nlevels(counts[[cluster]])
  if (n_pred > n_levels || n_cluster > n_levels) {
    # Plain-text message (no cli/ANSI formatting) so it displays cleanly in
    # shiny notifications; classed and carrying data so apps can catch it.
    rlang::warn(
      sprintf(
        paste(
          "Too many levels to plot (maximum %s): '%s' has %d level%s",
          "and '%s' has %d level%s."
        ),
        n_levels,
        pretty_var_name(pred),
        n_pred,
        if (n_pred == 1) "" else "s",
        pretty_var_name(cluster),
        n_cluster,
        if (n_cluster == 1) "" else "s"
      ),
      class = "clustering_confusion_too_many_levels",
      n_levels = n_levels,
      n_pred = n_pred,
      n_cluster = n_cluster
    )
    return(invisible(NULL))
  }

  # The variable with more levels goes on the rows (ties: pred on rows)
  # if (n_cluster > n_pred) {
  #   row_var <- cluster
  #   col_var <- pred
  # } else {
  #   row_var <- pred
  #   col_var <- cluster
  # }
  row_var <- pred
  col_var <- cluster

  counts <- switch(
    normalise,
    none = dplyr::mutate(counts, prop = n),
    pred = dplyr::mutate(counts, prop = n / sum(n), .by = dplyr::all_of(pred)),
    cluster = dplyr::mutate(
      counts,
      prop = n / sum(n),
      .by = dplyr::all_of(cluster)
    )
  ) |>
    dplyr::mutate(
      prop = dplyr::if_else(is.nan(prop), 0, prop),
      label = if (normalise == "none") {
        as.character(n)
      } else {
        scales::percent(prop, accuracy = 1)
      }
    )

  ggplot2::ggplot(
    counts,
    ggplot2::aes(x = .data[[col_var]], y = .data[[row_var]], fill = prop)
  ) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.5) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = label,
        colour = prop > max(prop, na.rm = TRUE) / 2
      ),
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_gradient(
      low = "grey95",
      high = "grey35",
      labels = if (normalise == "none") ggplot2::waiver() else scales::percent
    ) +
    ggplot2::scale_colour_manual(
      values = c(`FALSE` = "black", `TRUE` = "white")
    ) +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::labs(
      x = pretty_var_name(col_var),
      y = pretty_var_name(row_var),
      fill = switch(
        normalise,
        none = "Nodes",
        pred = paste("% of", pretty_var_name(pred)),
        cluster = "% of cluster"
      )
    ) +
    ggplot2::coord_fixed() +
    ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
}

if (sys.nframe() == 5) {
  get_clustering_measures(example_network, "site") |> print()
  plot_clustering_confusion(example_network, "site") |> print()
  plot_clustering_confusion(
    example_network,
    "site",
    normalise = "pred"
  ) |>
    print()
}

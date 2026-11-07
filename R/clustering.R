#' Add clusters
#'
#' Nodes with no connections to other nodes (isolates) are assigned to a
#' single cluster called "disconnected" for every clustering method, instead
#' of each being placed in its own singleton cluster.
#'
#' @param g igraph object
#' @param weight edge attribute to use for weighted clustering methods
#'
#' @returns adds clusters to igraph object
#'
#' @export
#' @examples
#' add_clustering(example_network)
add_clustering <- function(g, weight = "wij") {
  w <- igraph::edge_attr(g, weight)

  disconnected <- igraph::degree(g, loops = FALSE) == 0

  label_clusters <- function(prefix, communities) {
    m <- as.integer(igraph::membership(communities))
    out <- rep("disconnected", length(m))
    # Renumber connected clusters 1, 2, 3, ... with no gaps,
    # keeping the algorithm's original ordering
    m_conn <- m[!disconnected]
    out[!disconnected] <- stringr::str_c(
      prefix,
      match(m_conn, sort(unique(m_conn)))
    )
    out
  }

  igraph::V(g)$.louvain <- label_clusters(
    "L",
    igraph::cluster_louvain(g)
  )
  igraph::V(g)$.louvain_weighted <- label_clusters(
    "Lw",
    igraph::cluster_louvain(g, weights = w)
  )
  igraph::V(g)$.eigen <- label_clusters(
    "E",
    igraph::cluster_leading_eigen(g)
  )
  igraph::V(g)$.eigen_weighted <- label_clusters(
    "Ew",
    igraph::cluster_leading_eigen(g, weights = w)
  )
  igraph::V(g)$.label_prop <- label_clusters(
    "LP",
    igraph::cluster_label_prop(g)
  )
  igraph::V(g)$.label_prop_weighted <- label_clusters(
    "LPw",
    igraph::cluster_label_prop(g, weights = w)
  )
  g
}
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
          .by = dplyr::all_of(cluster)
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
      stringr::str_glue(
        "{pred} must be a categorical node attribute."
      )
    )
  }

  counts <- count_clusters_by_pred(df, pred, cluster)

  n_pred <- nlevels(counts[[pred]])
  n_cluster <- nlevels(counts[[cluster]])
  if (n_pred > n_levels || n_cluster > n_levels) {
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
      n_levels = n_levels,
      n_pred = n_pred,
      n_cluster = n_cluster
    )
    return(invisible(NULL))
  }

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
utils::globalVariables(
  c("cluster", "dim_1", "dim_2", "variable")
)
#' plot CA for clusters
#'
#'
#' @param g An igraph object.
#' @param pred Name of the vertex attribute to compare clusters against.
#' @param cluster Name of the vertex attribute holding cluster membership.
#' @param jitter_scale level to scale
#'
#' @return A ggplot object, or `NULL` with a warning if `pred` is not given.
plot_ca_clusters <- function(
  g,
  pred = NULL,
  cluster = ".louvain",
  jitter_scale = 10
) {
  if (is.null(pred)) {
    rlang::warn(
      "`pred` must name a vertex attribute to compare clusters against."
    )
    return(NULL)
  }
  vertices <- igraph::as_data_frame(g, what = "vertices")
  if (!is.character(vertices[[pred]]) && !is.factor(vertices[[pred]])) {
    rlang::abort(
      stringr::str_glue(
        "{pretty_var_name(pred)} must be a categorical node attribute.",
      )
    )
  }

  tab <- table(vertices[[cluster]], vertices[[pred]])

  ca <- FactoMineR::CA(tab, graph = FALSE)
  ca_clusters <- ca_coords(ca$row$coord, "cluster")
  ca_vars <- ca_coords(ca$col$coord, "variable")
  pct_var <- ca$eig[, 2]

  p_value <- stats::fisher.test(tab, simulate.p.value = TRUE)$p.value

  plot <- if (ncol(ca_clusters) == 2) {
    plot_ca_1d(ca_clusters, ca_vars, pct_var)
  } else {
    plot_ca_2d(ca_clusters, ca_vars, pct_var, jitter_scale)
  }

  plot +
    ggplot2::ggtitle(sprintf("Fisher Exact Test: %.4f", p_value)) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
}

ca_coords <- function(coord, id_col) {
  coord <- as.matrix(coord)
  colnames(coord) <- paste0("dim_", seq_len(ncol(coord)))
  tibble::as_tibble(coord, rownames = id_col)
}

dim_label <- function(pct_var, i) {
  sprintf("Dimension %d (%.2f%%)", i, pct_var[i])
}

# Single dimension: clusters above the line, predictor levels below it.
plot_ca_1d <- function(ca_clusters, ca_vars, pct_var) {
  ggplot2::ggplot(ca_clusters, ggplot2::aes(x = dim_1, y = 0)) +
    ggplot2::theme_bw() +
    ggplot2::geom_hline(
      yintercept = 0,
      linetype = "dashed",
      colour = "darkgrey"
    ) +
    ggplot2::geom_point(colour = "black", size = 2, shape = 4) +
    ggrepel::geom_text_repel(
      ggplot2::aes(label = cluster),
      direction = "y",
      nudge_y = 0.1,
      box.padding = 0.15,
      point.padding = 0,
      segment.size = 0.2,
      segment.color = "gray80",
      force = 0.5,
      colour = "black",
      size = 4
    ) +
    ggplot2::geom_point(
      data = ca_vars,
      colour = "darkblue",
      size = 2,
      shape = 19
    ) +
    ggrepel::geom_text_repel(
      data = ca_vars,
      ggplot2::aes(label = variable),
      direction = "y",
      nudge_y = -0.1,
      box.padding = 0.15,
      point.padding = 0,
      segment.size = 0.2,
      segment.color = "darkblue",
      force = 0.5,
      colour = "darkblue",
      fontface = "bold",
      size = 4
    ) +
    ggplot2::ylim(-0.5, 0.5) +
    ggplot2::labs(x = dim_label(pct_var, 1), y = NULL) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank()
    )
}

# Two or more dimensions: biplot of the first two.
plot_ca_2d <- function(ca_clusters, ca_vars, pct_var, jitter_scale) {
  label_jitter <- ggplot2::position_jitter(
    width = diff(range(ca_clusters$dim_1)) / jitter_scale,
    height = diff(range(ca_clusters$dim_2)) / jitter_scale
  )

  ggplot2::ggplot(ca_vars, ggplot2::aes(x = dim_1, y = dim_2)) +
    ggplot2::theme_bw() +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = "darkgrey",
      linetype = "dashed"
    ) +
    ggplot2::geom_vline(
      xintercept = 0,
      colour = "darkgrey",
      linetype = "dashed"
    ) +
    ggplot2::geom_point(colour = "darkblue") +
    ggrepel::geom_label_repel(
      ggplot2::aes(label = variable),
      colour = "darkblue",
      box.padding = 1
    ) +
    ggplot2::geom_text(
      data = ca_clusters,
      ggplot2::aes(label = cluster),
      position = label_jitter,
      alpha = 0.5
    ) +
    ggplot2::labs(x = dim_label(pct_var, 1), y = dim_label(pct_var, 2))
}

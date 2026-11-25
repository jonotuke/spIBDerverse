utils::globalVariables(
  c("sd", "n", "prop", "label", "type", "name")
)
utils::globalVariables(
  c("cluster", "dim_1", "dim_2", "variable")
)
#' Add clusters
#'
#' Nodes with no connections to other nodes (isolates) are assigned to a
#' single cluster called "disconnected" for every clustering method, instead
#' of each being placed in its own singleton cluster.
#'
#' @param g igraph object
#' @param weight edge attribute to use for weighted clustering methods
#' @param max_nodes max number of nodes for slow clustering
#'
#' @returns adds clusters to igraph object
#'
#' @export
#' @examples
#' add_clustering(example_network)
add_clustering <- function(g, weight = "wij", max_nodes = 500) {
  w <- igraph::edge_attr(g, weight)
  n_nodes <- igraph::vcount(g)

  disconnected <- igraph::degree(g, loops = FALSE) == 0

  label_clusters <- function(prefix, communities) {
    m <- as.integer(igraph::membership(communities))
    out <- rep("Disconnected", length(m))
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
  if (n_nodes > max_nodes) {
    igraph::V(g)$.eigen <- rep(NA, n_nodes)
  } else {
    igraph::V(g)$.eigen <- label_clusters(
      "E",
      igraph::cluster_leading_eigen(g)
    )
  }
  if (n_nodes > max_nodes) {
    igraph::V(g)$.eigen_weighted <- rep(NA, n_nodes)
  } else {
    igraph::V(g)$.eigen_weighted <- label_clusters(
      "E",
      igraph::cluster_leading_eigen(g, weight = w)
    )
  }
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


#' Given tibble cluster and pred,
#' @noRd
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

#' From igraph gets node info and clusterning as tibble
#' @noRd
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
#' @param normalise one of none, pred, or cluster
#' @param n_levels maximum number of levels
#' @param base_size size of text
#' @param fill_pal palette colour for fill
#' @param no_dis remove Disconnected nodes
#'
#' @returns a ggplot object
#' @export
#' @examples
#' plot_clustering_confusion(example_network_2, "Province")
plot_clustering_confusion <- function(
  g,
  pred,
  cluster = ".louvain",
  normalise = c("none", "pred", "cluster"),
  n_levels = 20,
  base_size = 14,
  fill_pal = "default",
  no_dis = FALSE
) {
  normalise <- match.arg(normalise)
  df <- clustering_vertex_df(g)
  if (no_dis) {
    df <- df |> dplyr::filter(.data[[cluster]] != "Disconnected")
  }
  if (!is.character(df[[pred]]) && !is.factor(df[[pred]])) {
    p <- df |>
      ggplot2::ggplot(
        ggplot2::aes(
          x = .data[[cluster]],
          y = .data[[pred]],
          fill = .data[[cluster]]
        )
      ) +
      ggplot2::geom_boxplot() +
      ggplot2::theme_bw() +
      ggplot2::labs(
        x = pretty_var_name(cluster),
        fill = pretty_var_name(cluster)
      ) +
      pal_scale(
        aesthetic = "fill",
        pal = fill_pal,
        type = "discrete"
      )
    return(p)
  }

  counts <- count_clusters_by_pred(df, pred, cluster)

  n_pred <- nlevels(counts[[pred]])
  n_cluster <- nlevels(counts[[cluster]])
  if (n_pred > n_levels || n_cluster > n_levels) {
    rlang::warn(
      "Too many levels to plot"
    )
    return(invisible(NULL))
  }

  row_var <- pred
  col_var <- cluster

  counts <- switch(
    normalise,
    none = dplyr::mutate(
      counts,
      prop = n
    ),
    pred = dplyr::mutate(
      counts,
      prop = n / sum(n),
      .by = dplyr::all_of(pred)
    ),
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
    ggplot2::aes(
      x = .data[[col_var]],
      y = .data[[row_var]],
      fill = prop
    )
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

#' plot CA for clusters
#'
#'
#' @param g An igraph object.
#' @param pred Name of the vertex attribute to compare clusters against.
#' @param cluster Name of the vertex attribute holding cluster membership.
#' @param jitter_scale level to scale
#' @param no_dis remove disconnected nodes
#'
#' @return A ggplot object
#' @export
#' @examples
#' plot_ca_clusters(example_network, "site")
plot_ca_clusters <- function(
  g,
  pred = NULL,
  cluster = ".louvain",
  jitter_scale = 10,
  no_dis = FALSE
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

  if (no_dis) {
    vertices <- vertices |>
      dplyr::filter(.data[[cluster]] != "Disconnected")
  }

  tab <- table(vertices[[cluster]], vertices[[pred]])

  ca <- FactoMineR::CA(tab, graph = FALSE)
  ca_clusters <- ca_coords(ca$row$coord, "cluster")
  ca_vars <- ca_coords(ca$col$coord, "variable")
  pct_var <- ca$eig[, 2]

  p_value <- stats::fisher.test(
    tab,
    simulate.p.value = TRUE
  )$p.value

  plot <- if (ncol(ca_clusters) == 2) {
    plot_ca_1d(ca_clusters, ca_vars, pct_var)
  } else {
    plot_ca_2d(ca_clusters, ca_vars, pct_var, jitter_scale)
  }

  plot +
    ggplot2::ggtitle(
      sprintf("Fisher Exact Test: %.4f", p_value)
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5)
    )
}

ca_coords <- function(coord, id_col) {
  coord <- as.matrix(coord)
  colnames(coord) <- paste0("dim_", seq_len(ncol(coord)))
  tibble::as_tibble(coord, rownames = id_col)
}

dim_label <- function(pct_var, i) {
  sprintf("Dimension %d (%.2f%%)", i, pct_var[i])
}

#' Single cluster plot
#' @noRd
plot_ca_1d <- function(ca_clusters, ca_vars, pct_var) {
  ggplot2::ggplot(
    ca_clusters,
    ggplot2::aes(x = dim_1, y = 0)
  ) +
    ggplot2::theme_bw() +
    ggplot2::geom_hline(
      yintercept = 0,
      linetype = "dashed",
      colour = "darkgrey"
    ) +
    ggplot2::geom_point(
      colour = "black",
      size = 2,
      shape = 4
    ) +
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
      size = 4,
      max.overlaps = 1e4
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
      size = 4,
      max.overlaps = 1e4
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

#' Two or more dimensions: biplot of the first two.
#' @noRd
plot_ca_2d <- function(ca_clusters, ca_vars, pct_var, jitter_scale) {
  label_jitter <- ggplot2::position_jitter(
    width = diff(range(ca_clusters$dim_1)) / jitter_scale,
    height = diff(range(ca_clusters$dim_2)) / jitter_scale
  )

  ggplot2::ggplot(
    ca_vars,
    ggplot2::aes(x = dim_1, y = dim_2)
  ) +
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
      box.padding = 1,
      max.overlaps = 1e4
    ) +
    ggplot2::geom_text(
      data = ca_clusters,
      ggplot2::aes(label = cluster),
      position = label_jitter,
      alpha = 0.5
    ) +
    ggplot2::labs(
      x = dim_label(pct_var, 1),
      y = dim_label(pct_var, 2)
    )
}

#' plot cluster HC
#'
#' @param g igraph object
#' @param cluster cluster column
#' @param pred pred column
#' @param no_dis remove nodes that are disconnected
#'
#' @returns HC tree
#'
#' @export
#' @examples
#' plot_cluster_hc(
#'    example_network,
#'    pred = "site"
#'  )
plot_cluster_hc <- function(g, cluster = ".louvain", pred, no_dis = FALSE) {
  vertices <- igraph::as_data_frame(g, what = "vertices")

  if (no_dis) {
    vertices <- vertices |>
      dplyr::filter(.data[[cluster]] != "Disconnected")
  }

  checkmate::assert_names(names(vertices), must.include = pred)

  if (any(is.character(vertices[[pred]]))) {
    tab <- table(vertices[[cluster]], vertices[[pred]])
    fit_ca <- FactoMineR::CA(X = tab, graph = FALSE)
    k <- min(5, base::ncol(fit_ca$row$coord))
    coords <- fit_ca$row$coord[, 1:k, drop = FALSE]
    d_mat <- stats::dist(x = coords, method = "euclidean")
    hc <- stats::hclust(d = d_mat, method = "ward.D2")

    dend_data <- ggdendro::dendro_data(model = hc, type = "rectangle")
  } else {
    # Requires more classical construction based on group median
    agg <- vertices |>
      dplyr::group_by(.data[[cluster]]) |>
      dplyr::summarise(x = stats::median(.data[[pred]])) |>
      dplyr::ungroup() |>
      dplyr::rename(label = dplyr::all_of(cluster))
    vals <- agg$x
    names(vals) <- agg$label
    d_mat <- stats::dist(x = vals, method = "euclidean")
    hc <- stats::hclust(d = d_mat, method = "ward.D2")

    dend_data <- ggdendro::dendro_data(model = hc, type = "rectangle")
  }
  gg.dendro <- ggplot2::ggplot(ggdendro::segment(dend_data)) +
    ggplot2::geom_segment(
      mapping = ggplot2::aes(x = x, y = y, xend = xend, yend = yend)
    ) +
    ggplot2::scale_x_continuous(
      breaks = ggdendro::label(dend_data)$x,
      labels = ggdendro::label(dend_data)$label
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5),
      plot.margin = ggplot2::margin(t = 1, r = 1, b = 1, l = 1, unit = "lines")
    )
  gg.dendro
}
# DRIVER ----
if (sys.nframe() == 5) {
  plot_cluster_hc(
    example_network_2,
    pred = "site",
    no_dis = TRUE
  ) |>
    print()
}

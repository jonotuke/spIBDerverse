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
  ggplot(ca_clusters, aes(x = dim_1, y = 0)) +
    theme_bw() +
    geom_hline(
      yintercept = 0,
      linetype = "dashed",
      colour = "darkgrey"
    ) +
    geom_point(colour = "black", size = 2, shape = 4) +
    ggrepel::geom_text_repel(
      aes(label = cluster),
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
    geom_point(
      data = ca_vars,
      colour = "darkblue",
      size = 2,
      shape = 19
    ) +
    ggrepel::geom_text_repel(
      data = ca_vars,
      aes(label = variable),
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
    ylim(-0.5, 0.5) +
    labs(x = dim_label(pct_var, 1), y = NULL) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank()
    )
}

# Two or more dimensions: biplot of the first two.
plot_ca_2d <- function(ca_clusters, ca_vars, pct_var, jitter_scale) {
  label_jitter <- position_jitter(
    width = diff(range(ca_clusters$dim_1)) / jitter_scale,
    height = diff(range(ca_clusters$dim_2)) / jitter_scale
  )

  ggplot(ca_vars, aes(x = dim_1, y = dim_2)) +
    theme_bw() +
    geom_hline(yintercept = 0, colour = "darkgrey", linetype = "dashed") +
    geom_vline(xintercept = 0, colour = "darkgrey", linetype = "dashed") +
    geom_point(colour = "darkblue") +
    ggrepel::geom_label_repel(
      aes(label = variable),
      colour = "darkblue",
      box.padding = 1
    ) +
    geom_text(
      data = ca_clusters,
      aes(label = cluster),
      position = label_jitter,
      alpha = 0.5
    ) +
    labs(x = dim_label(pct_var, 1), y = dim_label(pct_var, 2))
}

# Quick check when the file is sourced directly (e.g. RStudio's Source button).
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  plot_ca_clusters(example_network, "site") |> print()
}

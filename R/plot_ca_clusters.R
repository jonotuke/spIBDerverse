plot_ca_clusters <- function(
  g,
  pred = "none",
  cluster = ".louvain",
  factor = 10
) {
  if (pred == "none") {
    rlang::warn("Need a predictor")
    return(NULL)
  }
  df <- igraph::as_data_frame(g, what = "vertices") |>
    as_tibble()
  tab <- table(df[[cluster]], df[[pred]])
  ca <- FactoMineR::CA(tab, graph = FALSE)
  pv <- round(fisher.test(tab, simulate.p.value = TRUE)$p.value, 4)
  title <- stringr::str_glue("Fisher Exact Test: {pv}")
  ca_clusters <- ca$row$coord |>
    as.data.frame() |>
    rownames_to_column('cluster') |>
    janitor::clean_names() |>
    as_tibble()
  ca_var <- ca$col$coord |>
    as.data.frame() |>
    rownames_to_column('variable') |>
    janitor::clean_names() |>
    as_tibble()
  if (ncol(ca_clusters) == 2) {
    ca_clusters |>
      ggplot(aes(x = ca_row_coord, y = 0)) +
      theme_bw() +
      geom_hline(
        yintercept = 0,
        linetype = "dashed",
        color = "darkgrey"
      ) +
      geom_point(
        color = "black",
        size = 2,
        pch = 4
      ) +
      ggrepel::geom_text_repel(
        aes(label = cluster),
        direction = "y",
        nudge_y = 0.1,
        box.padding = 0.15,
        point.padding = 0,
        segment.size = 0.2,
        segment.color = "gray80",
        force = 0.5,
        color = "black",
        size = 4
      ) +
      geom_point(
        data = ca_var,
        aes(x = v1, y = 0),
        color = "darkblue",
        size = 2,
        pch = 19
      ) +
      ggrepel::geom_text_repel(
        data = ca_var,
        aes(x = v1, y = 0, label = variable),
        direction = "y",
        nudge_y = -0.1,
        box.padding = 0.15,
        point.padding = 0,
        segment.size = 0.2,
        segment.color = "darkblue",
        force = 0.5,
        color = "darkblue",
        fontface = "bold",
        size = 4
      ) +
      ggtitle(title) +
      theme(plot.title = element_text(hjust = 0.5)) +
      labs(x = "Dimension 1 (100.00%)", y = NULL) +
      theme(
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()
      ) +
      ylim(-0.5, 0.5)
  } else {
    ca_var |>
      ggplot(
        aes(
          x = dim_1,
          y = dim_2
        )
      ) +
      theme_bw() +
      geom_hline(
        yintercept = 0,
        col = 'darkgrey',
        linetype = 'dashed'
      ) +
      geom_vline(
        xintercept = 0,
        col = 'darkgrey',
        linetype = 'dashed'
      ) +
      geom_point(
        col = 'darkblue',
      ) +
      ggrepel::geom_label_repel(
        aes(label = variable),
        col = 'darkblue',
        box.padding = 1,
      ) +
      geom_text(
        aes(label = cluster),
        position = position_jitter(
          height = diff(range(ca_clusters$dim_1)) / factor,
          width = diff(range(ca_clusters$dim_2)) / factor
        ),
        alpha = 0.5,
        data = ca_clusters
      ) +
      ggtitle(title) +
      theme(plot.title = element_text(hjust = 0.5)) +
      scale_x_continuous(
        name = sprintf('Dimension 1 (%.2f%%)', ca$eig[1, 2])
      ) +
      scale_y_continuous(
        name = sprintf('Dimension 1 (%.2f%%)', ca$eig[2, 2])
      )
  }
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  plot_ca_clusters(example_network, "site") |> print()
}

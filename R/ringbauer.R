utils::globalVariables(
  c("grp1", "grp2", "density", "label", "text", "x", "y", "xend", "yend")
)

#' Add display labels to ringbauer measures
#'
#' Internal helper shared by [plot_ringbauer()] and
#' [convert_ringbauer_measures()]: optionally abbreviates group names, adds
#' group sizes and percentages to the labels, and adds a `text` column with
#' a legible text colour for each cell.
#'
#' @inheritParams convert_ringbauer_measures
#' @return `RM` with `grp1`, `grp2` and `label` as character, plus `text`
#' @noRd
prepare_ringbauer_labels <- function(
  RM,
  abbr = FALSE,
  addSize = FALSE,
  addPercent = FALSE
) {
  if (abbr) {
    RM <- dplyr::mutate(
      RM,
      grp1 = abbreviate_terms(grp1),
      grp2 = abbreviate_terms(grp2)
    )
  }
  if (addSize) {
    RM <- dplyr::mutate(
      RM,
      grp1 = stringr::str_glue("{grp1} (n = {n1})"),
      grp2 = stringr::str_glue("{grp2} (n = {n2})")
    )
  }
  if (addPercent) {
    RM <- dplyr::mutate(
      RM,
      label = stringr::str_glue("{label} ({round(density * 100, 2)}%)")
    )
  }
  dplyr::mutate(
    RM,
    dplyr::across(c(grp1, grp2, label), as.character),
    text = get_text_font(density, "text")
  )
}

#' Square matrix of one ringbauer column
#'
#' @param RM a ringbauer measure tibble (one row per ordered pair of groups)
#' @param value name of the column to put in the cells
#' @param fill value for pairs missing from `RM`
#' @return a matrix with groups as row and column names
#' @noRd
ringbauer_matrix <- function(RM, value, fill) {
  grps <- unique(c(RM$grp1, RM$grp2))
  m <- matrix(fill, length(grps), length(grps), dimnames = list(grps, grps))
  m[cbind(RM$grp1, RM$grp2)] <- RM[[value]]
  m
}

#' Convert ringbauer measures
#'
#' Converts the ringbauer measures into matrices. [plot_ringbauer()] no
#' longer needs this step, as it takes the output of
#' [get_ringbauer_measures()] directly; this is kept for code that uses the
#' matrices themselves.
#'
#' @param RM A ringbauer measure tibble
#' @param abbr a boolean that when true will shorten the group names
#' @param addSize adds size to group labels
#' @param addPercent add percent to labels
#'
#' @return a list of three matrices: density, labels, and text colour
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |>
#'   convert_ringbauer_measures()
convert_ringbauer_measures <- function(
  RM,
  abbr = FALSE,
  addSize = FALSE,
  addPercent = FALSE
) {
  RM <- prepare_ringbauer_labels(RM, abbr, addSize, addPercent)
  list(
    density = ringbauer_matrix(RM, "density", 0),
    labels = ringbauer_matrix(RM, "label", ""),
    text_colour = ringbauer_matrix(RM, "text", "white")
  )
}

#' Plot Ringbauer
#'
#' Plots ringbauer measures as a heatmap of edge densities, with groups
#' ordered by hierarchical clustering (distance = 1 - density) and the
#' dendrogram drawn above. Based on the Ringbauer paper and the layout of
#' `gplots::heatmap.2()`.
#'
#' @param RM a ringbauer measure tibble from [get_ringbauer_measures()]. The
#'   list of matrices from [convert_ringbauer_measures()] is also accepted,
#'   for backward compatibility; in that case `abbr`, `addSize` and
#'   `addPercent` are ignored, as the labels are already made.
#' @inheritParams convert_ringbauer_measures
#' @param label_size size of the cell labels, in mm (as in
#'   `ggplot2::geom_text()`). The row and column labels and the legend text
#'   are set to the same size.
#' @param show_dendrogram if `TRUE`, draw the dendrogram above the heatmap
#'
#' @return a ggplot, or a patchwork if `show_dendrogram = TRUE`; either can
#'   be modified further, e.g. with `& ggplot2::theme(...)`
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |>
#'   plot_ringbauer(addSize = TRUE)
plot_ringbauer <- function(
  RM,
  abbr = FALSE,
  addSize = FALSE,
  addPercent = FALSE,
  label_size = 3,
  show_dendrogram = TRUE
) {
  if (is.data.frame(RM)) {
    RM <- prepare_ringbauer_labels(RM, abbr, addSize, addPercent)
  } else if (all(c("density", "labels", "text_colour") %in% names(RM))) {
    m <- RM$density
    RM <- data.frame(
      grp1 = rownames(m)[row(m)],
      grp2 = colnames(m)[col(m)],
      density = c(RM$density),
      label = c(RM$labels),
      text = c(RM$text_colour)
    )
  } else {
    stop(
      "`RM` must be the output of get_ringbauer_measures().",
      call. = FALSE
    )
  }

  # Cluster groups; the distance between groups is 1 - density
  density_matrix <- ringbauer_matrix(RM, "density", 0)
  n_grps <- nrow(density_matrix)
  if (n_grps < 2) {
    stop("Need at least two groups to cluster.", call. = FALSE)
  }
  hc <- stats::hclust(stats::as.dist(1 - density_matrix))
  grp_order <- rownames(density_matrix)[hc$order]

  RM <- dplyr::mutate(
    RM,
    grp1 = factor(grp1, levels = grp_order),
    grp2 = factor(grp2, levels = grp_order)
  )

  # geom_text() sizes are in mm, theme sizes in points
  text_pt <- label_size * ggplot2::.pt

  heatmap <- ggplot2::ggplot(RM, ggplot2::aes(grp1, grp2, fill = density)) +
    ggplot2::geom_tile() +
    ggplot2::geom_text(
      ggplot2::aes(label = label, colour = text),
      size = label_size
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_fill_viridis_c(name = "Density") +
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = text_pt),
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5),
      legend.text = ggplot2::element_text(size = text_pt),
      legend.title = ggplot2::element_text(size = text_pt)
    )

  if (!show_dendrogram) {
    return(heatmap)
  }

  # Leaves of dendro_data() sit at x = 1..n in hc$order, matching the tiles
  segments <- ggdendro::segment(ggdendro::dendro_data(hc))
  dendrogram <- ggplot2::ggplot(segments) +
    ggplot2::geom_segment(
      ggplot2::aes(x = x, y = y, xend = xend, yend = yend)
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0.5, n_grps + 0.5),
      expand = c(0, 0)
    ) +
    ggplot2::theme_void()

  patchwork::wrap_plots(dendrogram, heatmap, ncol = 1, heights = c(1, 4))
}
utils::globalVariables(
  c(
    "name",
    "from",
    "to",
    "grp",
    "grp_from",
    "grp_to",
    "grp1",
    "grp2",
    "n",
    "n1",
    "n2",
    "n_edges",
    "n_possible_edges",
    "pv",
    "lwr",
    "upr",
    "prop_test"
  )
)
#' Get ringbauer measures
#'
#' Takes a network and a categorical node variable and calculates the intra-
#' and inter-level edge density for every pair of levels. Each density is
#' compared with the overall network density using a one-sample proportion
#' test, with FDR-adjusted p-values. The 95% confidence interval for each
#' density (from the same `prop.test()` call) is returned as `lwr` and `upr`.
#'
#' Nodes with a missing value of `grp` are dropped, along with their edges.
#' The network is treated as undirected.
#'
#' @param g igraph object with a `name` vertex attribute
#' @param grp a name of a categorical node variable
#'
#' @return tibble with one row per ordered pair of levels (`grp1`, `grp2`)
#'   and columns `n_edges`, `n1`, `n2`, `n_possible_edges`, `density`,
#'   `label`, `overall_density`, `lwr`, `upr`, `pv` and `adj_pv`
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site")
get_ringbauer_measures <- function(g, grp) {
  stopifnot(igraph::is_igraph(g), is.character(grp), length(grp) == 1)
  if (!"name" %in% igraph::vertex_attr_names(g)) {
    stop("`g` must have a `name` vertex attribute.", call. = FALSE)
  }
  if (!grp %in% igraph::vertex_attr_names(g)) {
    stop("`", grp, "` is not a vertex attribute of `g`.", call. = FALSE)
  }

  node_df <- igraph::as_data_frame(g, "vertices") |>
    tibble::as_tibble() |>
    dplyr::select(name, grp = dplyr::all_of(grp)) |>
    dplyr::filter(!is.na(grp))
  grps <- unique(node_df$grp)

  grp_sizes <- node_df |>
    dplyr::count(grp) |>
    dplyr::mutate(n = as.double(n))

  # Group membership of both ends of each edge (edges touching dropped
  # nodes fall out of the inner joins)
  edge_df <- igraph::as_data_frame(g, "edges") |>
    tibble::as_tibble() |>
    dplyr::select(from, to) |>
    dplyr::inner_join(
      dplyr::rename(node_df, grp_from = grp),
      by = c(from = "name")
    ) |>
    dplyr::inner_join(
      dplyr::rename(node_df, grp_to = grp),
      by = c(to = "name")
    )

  # Count each between-group edge in both orientations so that the
  # (A, B) and (B, A) rows both get the full count; within-group edges
  # are counted once
  edge_tally <- dplyr::bind_rows(
    dplyr::select(edge_df, grp1 = grp_from, grp2 = grp_to),
    edge_df |>
      dplyr::filter(grp_from != grp_to) |>
      dplyr::select(grp1 = grp_to, grp2 = grp_from)
  ) |>
    dplyr::count(grp1, grp2, name = "n_edges") |>
    dplyr::mutate(n_edges = as.double(n_edges))

  p <- igraph::edge_density(g)

  tidyr::expand_grid(grp1 = grps, grp2 = grps) |>
    dplyr::left_join(edge_tally, by = c("grp1", "grp2")) |>
    dplyr::left_join(
      dplyr::rename(grp_sizes, grp1 = grp, n1 = n),
      by = "grp1"
    ) |>
    dplyr::left_join(
      dplyr::rename(grp_sizes, grp2 = grp, n2 = n),
      by = "grp2"
    ) |>
    dplyr::mutate(
      n_edges = dplyr::coalesce(n_edges, 0),
      n_possible_edges = dplyr::if_else(
        grp1 == grp2,
        n1 * (n1 - 1) / 2,
        n1 * n2
      ),
      density = n_edges / n_possible_edges,
      label = stringr::str_glue("{n_edges}/{n_possible_edges}"),
      overall_density = p,
      prop_test = purrr::map2(
        n_edges,
        n_possible_edges,
        \(x, n) {
          tryCatch(
            {
              res <- stats::prop.test(x = x, n = n, p = p)
              tibble::tibble(
                lwr = res$conf.int[[1]],
                upr = res$conf.int[[2]],
                pv = res$p.value
              )
            },
            error = \(e) {
              tibble::tibble(lwr = NA_real_, upr = NA_real_, pv = NA_real_)
            }
          )
        }
      )
    ) |>
    tidyr::unnest(prop_test) |>
    dplyr::mutate(adj_pv = stats::p.adjust(pv, method = "fdr")) |>
    dplyr::relocate(n_edges, .after = grp2)
}
# DRIVER ----
if (sys.nframe() == 5) {
  get_ringbauer_measures(example_network, "site") |>
    plot_ringbauer() |>
    print()
}

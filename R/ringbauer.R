utils::globalVariables(
  c("grp1", "grp2", "density", "label", "text")
)
#' Convert ringbauer measures
#'
#' This converts the ringbauer measures into matrices of the correct form
#' for the plot function.
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
#' convert_ringbauer_measures()
convert_ringbauer_measures <- function(
  RM,
  abbr = FALSE,
  addSize = FALSE,
  addPercent = FALSE
) {
  if (abbr) {
    RM <- RM |>
      dplyr::mutate(
        grp1 = abbreviate_terms(grp1),
        grp2 = abbreviate_terms(grp2)
      )
  }
  if (addSize) {
    RM <- RM |>
      dplyr::mutate(
        grp1 = stringr::str_glue("{grp1} (n = {n1})"),
        grp2 = stringr::str_glue("{grp2} (n = {n2})")
      )
  }
  if (addPercent) {
    RM <- RM |>
      dplyr::mutate(
        label = stringr::str_glue("{label} ({round(density * 100, 2)}%)")
      )
  }
  RM <- RM |> dplyr::select(grp1, grp2, density, label)
  RM <- RM |>
    dplyr::mutate(
      fill = get_text_font(density),
      text = get_text_font(density, "text")
    )
  grps <- unique(c(RM$grp1, RM$grp2))
  n_grps <- length(grps)
  M <- matrix(0, ncol = n_grps, nrow = n_grps)
  L <- matrix("", ncol = n_grps, nrow = n_grps)
  C <- matrix("white", ncol = n_grps, nrow = n_grps)
  for (i in 1:n_grps) {
    for (j in 1:n_grps) {
      M[i, j] <- RM |>
        dplyr::filter(grp1 == grps[i], grp2 == grps[j]) |>
        dplyr::pull(density)
      L[i, j] <- RM |>
        dplyr::filter(grp1 == grps[i], grp2 == grps[j]) |>
        dplyr::pull(label)
      C[i, j] <- RM |>
        dplyr::filter(grp1 == grps[i], grp2 == grps[j]) |>
        dplyr::pull(text)
    }
  }
  colnames(M) <- grps
  rownames(M) <- grps
  colnames(L) <- grps
  rownames(L) <- grps
  colnames(C) <- grps
  rownames(C) <- grps
  list(
    density = M,
    labels = L,
    text_colour = C
  )
}
#' Plot Ringbauer
#'
#' Takes the Ringbauer matrix and plots it. This was based on the Ringbauer paper and also the heatmap.2 function from gplots
#'
#' @param RM a Ringbauer matrix object
#' @param label_margin the margin around the heatmap - adjust to get enough space for labels
#' @param label_size adjust label and axis text
#'
#' @return Ringbauer plot
#' @importFrom graphics lines
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |>
#' convert_ringbauer_measures() |>
#' plot_ringbauer(label_margin = 10, label_size = 3)
plot_ringbauer <- function(RM, label_margin = 2, label_size = 3) {
  # Grab graphics parameters so can reset
  op <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(op))

  # Get the dendrogram
  ## the distance between groups is 1 - density
  dist <- stats::as.dist(1 - RM$density)
  ## Get tree
  hc <- stats::hclust(dist)
  dendro <- stats::as.dendrogram(hc)

  # Reorder groups based on dendrogram
  orders <- stats::order.dendrogram(dendro)
  density <- RM$density[orders, orders]
  labels <- RM$labels[orders, orders]
  text_colour <- RM$text_colour[orders, orders]

  # Set up layour for heatmap
  hm_lay <- graphics::layout(
    mat = matrix(c(2, 0, 1, 3), byrow = TRUE, ncol = 2),
    widths = c(7, 0.5),
    heights = c(1, 4),
    respect = FALSE
  )
  # Add heatmap
  graphics::par(mar = c(label_margin, label_margin, 0, 0))
  nr <- dim(density)[1]
  nc <- dim(density)[2]
  breaks <- seq(
    min(density, na.rm = TRUE),
    max(density, na.rm = TRUE),
    length = 15
  )
  ## Tiles
  graphics::image(
    1:nc,
    1:nr,
    density,
    xlim = 0.5 + c(0, nc),
    ylim = 0.5 + c(0, nr),
    axes = FALSE,
    xlab = "",
    ylab = "",
    col = viridis::viridis(14),
    breaks = breaks
  )
  ## Labels
  graphics::text(
    x = c(row(labels)),
    y = c(col(labels)),
    labels = c(labels),
    col = text_colour,
    cex = label_size
  )
  # graphics::axis(
  #   1,
  #   at = seq(1, nc, by = 1),
  #   labels = colnames(density),
  #   cex.axis = label_size,
  #   padj = 1
  # )
  graphics::axis(
    1,
    at = seq(1, nc, by = 1),
    labels = colnames(density),
    cex.axis = label_size,
    las = 2,
    padj = 0.5
  )
  ypos <- graphics::axis(
    2,
    at = seq(1, nr, by = 1),
    # labels = rownames(density),
    labels = FALSE,
    cex.axis = 3,
    srt = 45
  )
  text(
    x = graphics::par("usr")[1] - 0.3,
    y = ypos,
    labels = rownames(density),
    cex = label_size,
    srt = 0,
    xpd = NA,
    adj = 1,
    padj = 0.5
  )

  # Add dendrogram
  graphics::par(mar = c(0, label_margin, 0, 0))
  plot(dendro, axes = FALSE, xaxs = "i", leaflab = "none")

  # Add legend
  graphics::par(mar = c(label_margin, 0.1, 0, 1.9))
  z <- matrix(breaks, ncol = 15, nrow = 1)
  graphics::image(
    1:2,
    1:16,
    z = z,
    col = viridis::viridis(14),
    breaks = breaks,
    xaxt = "n",
    xlab = NA,
    yaxt = "n"
  )
  graphics::axis(
    4,
    at = seq(1.5, 15.5, by = 1),
    labels = round(breaks, 2)
  )
  invisible(RM)
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

#' Plot Ringbauer
#'
#' Takes the Ringbauer matrix and plots it. This was based on the Ringbauer paper and also the heatmap.2 function from gplots
#'
#' @param RM a Ringbauer matrix object
#' @param label_margin the margin around the heatmap - adjust to get enough space for labels
#' @param label_size adjust label and axis text
#'
#' @return Ringbauer plot
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
  graphics::axis(
    1,
    at = seq(1, nc, by = 1),
    labels = colnames(density),
    cex.axis = label_size,
    padj = 1
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
    x = graphics::par("usr")[1],
    y = ypos,
    labels = rownames(density),
    cex = label_size,
    srt = 0,
    xpd = NA,
    adj = 1.5
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
# get_ringbauer_measures(example_network, "site") |>
#   convert_ringbauer_measures() |>
#   plot_ringbauer(label_margin = 10, label_size = 8) |>
#   print()

utils::globalVariables(
  c("pixel")
)
plot_default_image <- function() {
  spIBDerverse::default_image |>
    ggplot2::ggplot(
      ggplot2::aes(col, row, label = pixel)
    ) +
    ggplot2::geom_text() +
    ggplot2::scale_y_reverse() +
    ggplot2::theme_void() +
    ggplot2::coord_equal(ratio = 2)
}
# plot_default_image()

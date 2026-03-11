plot_map <- function(
  network_sf,
  zoom = 1
) {
  nodes_sf <- network_sf$nodes_sf
  edges_sf <- network_sf$edges_sf
  ggplot2::ggplot(nodes_sf) +
    ggspatial::annotation_map_tile(
      zoom = zoom
    ) +
    ggplot2::geom_sf(data = edges_sf, col = "grey30") +
    ggplot2::geom_sf(ggplot2::aes(fill = col), pch = 21) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::geom_sf_label(
      ggplot2::aes(label = label),
      size = 2,
      color = "blue"
    )
}
# example_network
# network_sf <- convert_sf(example_network, "lat", "long", "site")
# network_sf
# plot_map(network_sf, zoom = 15) |> print()

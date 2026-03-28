# plot static-map

plot static-map

## Usage

``` r
plot_staticmap(
  sf,
  key = NULL,
  zoom = 5,
  maptype = "stamen_terrain",
  lon_range = NULL,
  lat_range = NULL,
  fill = "none",
  shape = "none",
  node_size = 4,
  node_centrality = "none",
  connected = "Show",
  edge = "none",
  edge_legend = TRUE,
  edge_trans = "identity",
  label = "",
  label_inc = "",
  label_exc = "",
  label_size = 3,
  theme = "minimal"
)
```

## Arguments

- sf:

  network sf pobject

- key:

  stadia API key

- zoom:

  stadia tile zoom

- maptype:

  stadia map tile

- lon_range:

  range of lon to zoom to

- lat_range:

  range of lat to zoom to

- fill:

  vertex attribute for node fill

- shape:

  vertex attribute for node shape

- node_size:

  node size

- node_centrality:

  vertext attribute for node alpha

- connected:

  choice for how to deal with isolated nodes with choices Hide, Show,
  Grey out

- edge:

  edge attribute for line colour

- edge_legend:

  boolean to control edge legend

- edge_trans:

  transformation for edge mapping

- label:

  vertex attribute to use for labels

- label_inc:

  regular expression to include labels

- label_exc:

  regular expression to exclude labels

- label_size:

  label size

- theme:

  type of plot theme

## Value

network plot

## Examples

``` r
plot_network(example_network)
#> Warning: Removed 40 rows containing missing values or values outside the scale range
#> (`geom_text()`).
```

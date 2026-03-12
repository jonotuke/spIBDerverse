# plot static map

plot static map

## Usage

``` r
plot_static_map(
  network_sf,
  zoom = NULL,
  maptype = "stamen_terrain",
  key = NULL,
  fill_col = "",
  shape_col = "",
  edge_col = "",
  lon_range = NULL,
  lat_range = NULL,
  theme = "minimal",
  pt_size = 3
)
```

## Arguments

- network_sf:

  a network sf object

- zoom:

  level of tile resolution

- maptype:

  type of tile

- key:

  API key for stadia

- fill_col:

  node attribute for fill

- shape_col:

  node attribute for shape

- edge_col:

  edge attribute for edge width and colour

- lon_range:

  lon range to zoom

- lat_range:

  lat range to zoom

- theme:

  type of ggplot

- pt_size:

  node size

## Value

plot of network with background tiles

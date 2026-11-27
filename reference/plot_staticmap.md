# Plot a network on a static Stadia map

Draws the network with
[`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md)
using a geographic layout, then places a Stadia map tile underneath it.
All styling (edges, nodes, labels, palettes, ...) is handled by
[`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md),
so any changes made there carry through automatically.

## Usage

``` r
plot_staticmap(
  g,
  key = NULL,
  lat = "lat",
  long = "long",
  zoom = 5,
  maptype = "stamen_terrain",
  lon_range = NULL,
  lat_range = NULL,
  pad = 0.05,
  jitter = 0,
  seed = 2026,
  country_lines = FALSE,
  theme = "minimal",
  ...
)
```

## Arguments

- g:

  An igraph network.

- key:

  Stadia API key. See <https://stadiamaps.com>.

- lat, long:

  Vertex attributes holding latitude and longitude.

- zoom:

  Stadia tile zoom.

- maptype:

  Stadia map tile type.

- lon_range, lat_range:

  Optional length-2 vectors. If both are supplied, the network is
  filtered to nodes inside this box and the map is cropped to it.

- pad:

  Fraction of the node extent added around the edges of the map when
  `lon_range`/`lat_range` are not supplied.

- jitter:

  Maximum random shift (in degrees) applied to each node's position, so
  nodes in the same place don't overlap. Passed to
  [`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md),
  so it is applied after filtering by `lon_range`/`lat_range`. When the
  ranges are not supplied, the map is widened by `jitter` on each side
  so no jittered node is cropped.

- seed:

  Random seed passed to
  [`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md)
  (used for the jitter).

- country_lines:

  Add country lines `FALSE` (default) adds none, `TRUE` adds the
  `"stamen_toner_lines"` layer, or give a lines layer by name:
  `"stamen_toner_lines"` or `"stamen_terrain_lines"`.

- theme:

  Plot theme: "minimal", "black white", "void", or "blank" (keeps the
  theme from
  [`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md)).

- ...:

  Further arguments passed to
  [`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md),
  e.g. `fill`, `shape`, `edge`, `label`, `node_size`, `pal`.

## Value

A ggplot object, or `NULL` (invisibly) if no key is given.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_staticmap(example_network, key = my_key, zoom = 11, fill = "site")

# Continental scale, with country boundaries
plot_staticmap(
  europe_network,
  key = my_key,
  zoom = 4,
  country_lines = TRUE,
  fill = "region",
  label = "site"
)
} # }
```

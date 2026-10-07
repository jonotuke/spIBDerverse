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
  nodes in the same place don't overlap. Applied after filtering by
  `lon_range`/`lat_range`.

- seed:

  Random seed used for the jitter (and passed to
  [`plot_network()`](https://jonotuke.github.io/spIBDerverse/reference/plot_network.md)).

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
} # }
```

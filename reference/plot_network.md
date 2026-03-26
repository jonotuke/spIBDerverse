# plot network

plot network

## Usage

``` r
plot_network(
  g,
  seed = 2026,
  connected = "Show",
  edge = "none",
  edge_legend = TRUE,
  edge_trans = "identity",
  label = "none",
  label_size = 4,
  label_inc = "",
  label_exc = "",
  fill = "none",
  shape = "none",
  node_size = 5,
  node_centrality = "none"
)
```

## Arguments

- g:

  network

- seed:

  seed to set node locations

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

- label_size:

  label size

- label_inc:

  regular expression to include labels

- label_exc:

  regular expression to exclude labels

- fill:

  vertex attribute for node fill

- shape:

  vertex attribute for node shape

- node_size:

  node size

- node_centrality:

  vertext attribute for node alpha

## Value

network plot

## Examples

``` r
plot_network(example_network)
#> Warning: Removed 40 rows containing missing values or values outside the scale range
#> (`geom_text()`).
```

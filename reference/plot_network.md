# plot ggnet

plot ggnet

## Usage

``` r
plot_network(
  g,
  fill_col = "none",
  shape_col = "none",
  node_alpha_col = "none",
  edge_col = "none",
  edge_trans = "identity",
  edge_legend = TRUE,
  node_size = 4,
  text_size = 4,
  text_col = "black",
  labels = FALSE,
  label_col = "",
  label_inc = "",
  label_exc = "",
  connected = "Show"
)
```

## Arguments

- g:

  network

- fill_col:

  vertex attribute for node fill

- shape_col:

  vertex attribute for node shape

- node_alpha_col:

  vertext attribute for node alpha

- edge_col:

  edge attribute for line colour

- edge_trans:

  transformation for edge mapping

- edge_legend:

  boolean to control edge legend

- node_size:

  node size

- text_size:

  label size

- text_col:

  text colour

- labels:

  add labels

- label_col:

  vertex attribute to use for labels

- label_inc:

  regular expression to include labels

- label_exc:

  regular expression to exclude labels

- connected:

  choice for how to deal with isolated nodes with choices Hide, Show,
  Grey out

## Value

network plot

## Examples

``` r
plot_network(example_network)
#> Warning: Removed 40 rows containing missing values or values outside the scale range
#> (`geom_text()`).
```

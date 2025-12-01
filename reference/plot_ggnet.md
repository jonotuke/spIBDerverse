# plot ggnet

plot ggnet

## Usage

``` r
plot_ggnet(
  ggnet_obj,
  fill_col = "",
  shape_col = "",
  node_size = 4,
  text_size = 4,
  labels = FALSE,
  label_col = "",
  label_inc = "",
  label_exc = "",
  connected = "Show"
)
```

## Arguments

- ggnet_obj:

  ggnetwork dataframe

- fill_col:

  vertex attribute for node fill

- shape_col:

  vertex attribute for node shape

- node_size:

  node size

- text_size:

  label size

- labels:

  add labels

- label_col:

  vertex attribute to use for labels

- label_inc:

  regular expression to include labels

- label_exc:

  regular expression to exclude labels

- connected:

  choice for how to deal with isolated nodes

## Value

ggnetwork plot

## Examples

``` r
example_ggnet <- ggnetwork::ggnetwork(example_network)
plot_ggnet(example_ggnet)
#> Warning: Removed 151 rows containing missing values or values outside the scale range
#> (`geom_text()`).
```

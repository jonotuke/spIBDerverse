# Plot cluster membership against a categorical predictor

Plot cluster membership against a categorical predictor

## Usage

``` r
plot_clustering_confusion(
  g,
  pred,
  cluster = ".louvain",
  normalise = c("none", "pred", "cluster"),
  n_levels = 20,
  base_size = 14,
  fill_pal = "default",
  no_dis = FALSE
)
```

## Arguments

- g:

  igraph object with clustering

- pred:

  character node attribute to cross-tabulate against.

- cluster:

  clustering measure

- normalise:

  one of `"none"` (raw counts), `"pred"` (proportion of each predictor
  level falling in each cluster) or `"cluster"` (composition of each
  cluster).

- n_levels:

  maximum number of levels

- base_size:

  size of text

- fill_pal:

  palette colour for fill

- no_dis:

  remove Disconnected nodes

## Value

a ggplot object, or `NULL` (invisibly) if `pred` or `cluster` has more
than `n_levels` levels.

## Examples

``` r
plot_clustering_confusion(example_network_2, "Province")
```

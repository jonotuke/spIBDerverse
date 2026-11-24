# plot CA for clusters

plot CA for clusters

## Usage

``` r
plot_ca_clusters(
  g,
  pred = NULL,
  cluster = ".louvain",
  jitter_scale = 10,
  no_dis = FALSE
)
```

## Arguments

- g:

  An igraph object.

- pred:

  Name of the vertex attribute to compare clusters against.

- cluster:

  Name of the vertex attribute holding cluster membership.

- jitter_scale:

  level to scale

- no_dis:

  remove disconnected nodes

## Value

A ggplot object, or `NULL` with a warning if `pred` is not given.

## Examples

``` r
plot_ca_clusters(example_network, "site")
```

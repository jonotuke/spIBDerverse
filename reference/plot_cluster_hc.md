# plot cluster HC

plot cluster HC

## Usage

``` r
plot_cluster_hc(g, cluster = ".louvain", pred, no_dis = FALSE)
```

## Arguments

- g:

  igraph object

- cluster:

  cluster column

- pred:

  pred column

- no_dis:

  remove nodes that are disconnected

## Value

HC tree

## Examples

``` r
plot_cluster_hc(
   example_network,
   pred = "site"
 )
```

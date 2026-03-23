# plot centrality measures

plot centrality measures

## Usage

``` r
plot_centrality(g, measure = "degree", facets = NULL)
```

## Arguments

- g:

  igraph obj

- measure:

  centrality measure to plot

- facets:

  attributes to facet plot on

## Value

histogram or barchart

## Examples

``` r
plot_centrality(example_network)
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.
```

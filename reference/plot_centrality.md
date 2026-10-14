# Plot centrality measures

Computes closeness, betweenness and eigenvector centrality for every
vertex of `g` and plots the chosen measure. Without `preds` a histogram
of the measure is drawn; with `preds` a boxplot is drawn for each
combination of the facet attributes, ordered by the median of the
measure.

## Usage

``` r
plot_centrality(g, centrality = ".degree", preds = NULL, rotate = FALSE)
```

## Arguments

- g:

  An igraph object.

- centrality:

  centrality measures

- preds:

  Preditors for centrality

- rotate:

  If `TRUE`, rotate the x-axis labels by 90 degrees.

## Value

A ggplot object: a histogram if `preds` is `NULL`, otherwise a boxplot.

## Examples

``` r
plot_centrality(example_network)
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

plot_centrality(example_network, "closeness", rotate = TRUE)
#> Error: Unknown centrality or preds: closeness
```

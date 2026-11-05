# test centralities

test centralities

## Usage

``` r
test_centralities(g, centrality, preds)
```

## Arguments

- g:

  An igraph object.

- centrality:

  Name of the centrality measure to plot. Either a vertex attribute of
  `g` (e.g. `".degree"`) or one of the computed measures: `"closeness"`,
  `"betweenness"` or `"eigen_centrality"`.

- preds:

  predss to test

## Value

table indicating any significant predictors

## Examples

``` r
test_centralities(example_network, c(".degree", ".closeness"), "genetic_sex")
#> # A tibble: 2 × 3
#>   predictor   centrality    pv
#>   <chr>       <chr>      <dbl>
#> 1 genetic_sex .degree    0.802
#> 2 genetic_sex .closeness 0.960
```

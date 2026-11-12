# Test centrality empirical

Tests using empirical method

## Usage

``` r
test_centrality_emp(g, centrality = ".degree", preds = NULL, n_sims = 999)
```

## Arguments

- g:

  An igraph object.

- centrality:

  Name of the centrality measure to plot. Either a vertex attribute of
  `g` (e.g. `".degree"`) or one of the computed measures: `"closeness"`,
  `"betweenness"` or `"eigen_centrality"`.

- preds:

  preds to test

- n_sims:

  number of sims

## Value

table indicating any significant predictors

## Examples

``` r
test_centrality_emp(example_network, ".degree", "genetic_sex")
#> # A tibble: 1 × 3
#>   predictor   centrality    pv
#>   <chr>       <chr>      <dbl>
#> 1 genetic_sex .degree     0.98
```

# Test centrality measures

Tests using a linear model if any of the predictors are significantly
associated with a given centrality measure

## Usage

``` r
test_centrality(g, measure = ".degree", predictor = NULL)
```

## Arguments

- g:

  An igraph object.

- measure:

  Name of the centrality measure to plot. Either a vertex attribute of
  `g` (e.g. `".degree"`) or one of the computed measures: `"closeness"`,
  `"betweenness"` or `"eigen_centrality"`.

- predictor:

  predictors to test

## Value

table indicating any significant predictors

## Examples

``` r
test_centrality(example_network, ".degree", "genetic_sex")
#> # A tibble: 1 × 2
#>   term        p.value
#>   <chr>         <dbl>
#> 1 genetic_sex   0.933
```

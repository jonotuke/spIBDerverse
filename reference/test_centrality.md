# Test centrality centralitys

Tests using a linear model if any of the predss are significantly
associated with a given centrality measure

## Usage

``` r
test_centrality(g, centrality = ".degree", preds = NULL)
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
test_centrality(example_network, ".degree", "genetic_sex")
#> # A tibble: 1 × 3
#>   term        p.value centrality
#>   <chr>         <dbl> <chr>     
#> 1 genetic_sex   0.933 .degree   
```

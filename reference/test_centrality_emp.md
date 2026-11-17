# Test centrality empirical

Tests using empirical method

## Usage

``` r
test_centrality_emp(
  g,
  centrality = ".degree",
  preds = NULL,
  n_sims = 999,
  min_alpha = 0.01
)
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

- min_alpha:

  min alpha

## Value

table indicating any significant predictors

## Examples

``` r
test_centrality_emp(example_network, ".degree", "genetic_sex")
#> # A tibble: 1 × 4
#>   predictor   centrality KW_pv dunn            
#>   <chr>       <chr>      <dbl> <list>          
#> 1 genetic_sex .degree    0.982 <tibble [1 × 4]>
```

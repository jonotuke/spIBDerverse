# Get network node information

Get network node information

## Usage

``` r
get_node_info(g)
```

## Arguments

- g:

  ibd network object

## Value

tibble of node information

## Examples

``` r
get_node_info(example_network)
#> # A tibble: 40 × 15
#>    genetic_sex site  name  Degree Closeness Betweenness `Eigen-centrality`
#>    <chr>       <chr> <chr>  <dbl>     <dbl>       <dbl>              <dbl>
#>  1 F           B     1          5    0.01         3.97               0.301
#>  2 M           C     2          8    0.0115      14.8                0.708
#>  3 M           C     3          6    0.0112       0.966              0.665
#>  4 F           B     4          4    0.0101       5.13               0.272
#>  5 F           C     5          6    0.0118       7.76               0.623
#>  6 F           B     6          9    0.0130      49.2                0.594
#>  7 M           B     7          4    0.0104      15.6                0.218
#>  8 M           C     8         11    0.0137      63.7                0.971
#>  9 M           B     9          4    0.0108      11.3                0.256
#> 10 M           C     10         9    0.0127      44.1                0.785
#> # ℹ 30 more rows
#> # ℹ 8 more variables: Louvain <chr>, `Weighted Louvain` <chr>,
#> #   `Leading eigenvalue` <chr>, `Weighted leading eigenvalue` <chr>,
#> #   `Label propagation` <chr>, `Weighted label propagation` <chr>, lat <dbl>,
#> #   long <dbl>
```

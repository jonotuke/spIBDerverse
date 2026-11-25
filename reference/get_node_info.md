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
#> # A tibble: 40 × 16
#>    genetic_sex site  name  Degree Closeness Betweenness `Eigen-centrality`
#>    <chr>       <chr> <chr>  <dbl>     <dbl>       <dbl>              <dbl>
#>  1 F           A     1          3   0.00909       12.3               0.220
#>  2 M           A     2          5   0.0111        21.3               0.619
#>  3 M           A     3          5   0.0118        35.0               0.572
#>  4 F           B     4          5   0.0104        48.6               0.414
#>  5 F           A     5          2   0.00917        1.93              0.200
#>  6 F           C     6          5   0.00980        6.74              0.474
#>  7 M           C     7          4   0.00855        1.43              0.348
#>  8 M           A     8          6   0.0110        36.3               0.582
#>  9 M           C     9          4   0.00990       10.2               0.369
#> 10 M           B     10         5   0.0116        39.1               0.505
#> # ℹ 30 more rows
#> # ℹ 9 more variables: Louvain <chr>, `Weighted Louvain` <chr>,
#> #   `Leading eigenvalue` <chr>, `Weighted leading eigenvalue` <chr>,
#> #   `Label propagation` <chr>, `Weighted label propagation` <chr>, lat <dbl>,
#> #   long <dbl>, `SpIBDer-crawl` <chr>
```

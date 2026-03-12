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
#> # A tibble: 40 × 6
#>    genetic_sex site   name degree   lat  long
#>    <chr>       <chr> <int>  <dbl> <dbl> <dbl>
#>  1 F           C         1      4 -34.8  139.
#>  2 F           B         2      5 -34.9  139.
#>  3 M           B         3      5 -34.9  139.
#>  4 M           C         4     10 -34.8  139.
#>  5 F           C         5      6 -34.8  139.
#>  6 M           A         6      5 -34.9  139.
#>  7 M           C         7      8 -34.8  139.
#>  8 F           C         8      7 -34.8  139.
#>  9 M           A         9      7 -34.9  139.
#> 10 F           B        10      6 -34.9  139.
#> # ℹ 30 more rows
```

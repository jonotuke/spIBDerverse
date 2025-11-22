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
#>  1 F           A         1      1 -34.9  139.
#>  2 M           A         2      6 -34.9  139.
#>  3 M           C         3     11 -34.8  139.
#>  4 M           C         4      5 -34.8  139.
#>  5 M           C         5      5 -34.8  139.
#>  6 F           A         6      2 -34.9  139.
#>  7 M           B         7      7 -34.9  139.
#>  8 F           C         8      7 -34.8  139.
#>  9 F           B         9      4 -34.9  139.
#> 10 M           B        10      6 -34.9  139.
#> # ℹ 30 more rows
```

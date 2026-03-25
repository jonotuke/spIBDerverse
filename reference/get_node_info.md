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
#> # A tibble: 40 × 9
#>    genetic_sex site   name degree closeness betweenness eigencentrality   lat
#>    <chr>       <chr> <int>  <dbl>     <dbl>       <dbl>           <dbl> <dbl>
#>  1 F           C         1      4   0.00943       14.2           0.188  -34.8
#>  2 F           C         2      4   0.0103        23.3           0.278  -34.8
#>  3 F           C         3      3   0.00901       13.4           0.148  -34.8
#>  4 F           A         4      2   0.00775        2.19          0.0541 -34.9
#>  5 F           B         5      4   0.0102        26.0           0.238  -34.9
#>  6 M           A         6      6   0.0115        51.9           0.508  -34.9
#>  7 F           A         7      3   0.0102        23.0           0.192  -34.9
#>  8 F           A         8      4   0.00943       29.5           0.120  -34.9
#>  9 M           B         9      6   0.0112        26.3           0.601  -34.9
#> 10 M           B        10      4   0.0108        14.0           0.433  -34.9
#> # ℹ 30 more rows
#> # ℹ 1 more variable: long <dbl>
```

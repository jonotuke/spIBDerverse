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
#>    genetic_sex site  name  .degree .closeness .betweenness .eigencentrality
#>    <chr>       <chr> <chr>   <dbl>      <dbl>        <dbl>            <dbl>
#>  1 F           A     1           5     0.0112        18.2             0.225
#>  2 F           B     2           7     0.0118        29.1             0.256
#>  3 M           A     3           3     0.0102         3.27            0.183
#>  4 F           A     4           6     0.0118        27.9             0.258
#>  5 M           A     5           7     0.0132        34.6             0.415
#>  6 M           B     6           9     0.0127        39.9             0.457
#>  7 M           A     7           3     0.0102         2.73            0.186
#>  8 M           B     8           9     0.0120        28.5             0.497
#>  9 F           B     9           8     0.0122        53.2             0.360
#> 10 F           B     10          5     0.01           6.91            0.153
#> # ℹ 30 more rows
#> # ℹ 8 more variables: .louvain <chr>, .louvain_weighted <chr>, .eigen <chr>,
#> #   .eigen_weighted <chr>, .label_prop <chr>, .label_prop_weighted <chr>,
#> #   lat <dbl>, long <dbl>
```

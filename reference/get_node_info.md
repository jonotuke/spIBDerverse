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
#>  1 F           C     1          12    0.0135         64.5             0.986
#>  2 M           C     2           5    0.0111          6.23            0.325
#>  3 M           B     3           8    0.0125         39.1             0.360
#>  4 F           C     4           7    0.0105          9.87            0.633
#>  5 F           C     5          10    0.0120         15.4             0.893
#>  6 F           B     6           6    0.0122         54.6             0.301
#>  7 F           B     7           3    0.00962        10.4             0.147
#>  8 M           A     8           4    0.00952         5.81            0.130
#>  9 F           C     9          11    0.0123         48.2             0.882
#> 10 M           A     10          4    0.0102          8.04            0.142
#> # ℹ 30 more rows
#> # ℹ 8 more variables: .louvain <chr>, .louvain_weighted <chr>, .eigen <chr>,
#> #   .eigen_weighted <chr>, .label_prop <chr>, .label_prop_weighted <chr>,
#> #   lat <dbl>, long <dbl>
```

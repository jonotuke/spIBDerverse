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
#>  1 F           C     1           9    0.0122         24.0             0.748
#>  2 F           C     2           9    0.0127         25.1             0.841
#>  3 F           B     3           5    0.0110         15.1             0.268
#>  4 M           A     4           2    0.00935         1.21            0.122
#>  5 F           C     5          10    0.0132         31.1             0.880
#>  6 F           B     6           6    0.0120         18.0             0.390
#>  7 M           C     7          13    0.0137         88.7             1.000
#>  8 M           A     8           3    0.0102          3.50            0.218
#>  9 M           B     9           4    0.0102          6.62            0.142
#> 10 F           A     10          4    0.0106         14.2             0.166
#> # ℹ 30 more rows
#> # ℹ 8 more variables: .louvain <chr>, .louvain_weighted <chr>, .eigen <chr>,
#> #   .eigen_weighted <chr>, .label_prop <chr>, .label_prop_weighted <chr>,
#> #   lat <dbl>, long <dbl>
```

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
#>    genetic_sex site  name  .degree .closeness .betweenness .eigencentrality
#>    <chr>       <chr> <chr>   <dbl>      <dbl>        <dbl>            <dbl>
#>  1 F           A     1           6    0.0118          85.7          0.181  
#>  2 M           C     2          10    0.0127          64.3          0.865  
#>  3 M           A     3           1    0.00741          0            0.0610 
#>  4 F           A     4           3    0.00962         18.8          0.0594 
#>  5 M           C     5           7    0.0115          57.9          0.517  
#>  6 F           A     6           3    0.0105          23.8          0.248  
#>  7 F           C     7           6    0.0115          22.6          0.455  
#>  8 F           A     8           1    0.00704          0            0.00961
#>  9 M           B     9           4    0.0101          29.1          0.205  
#> 10 M           C     10         11    0.0127          75.1          0.887  
#> # ℹ 30 more rows
#> # ℹ 2 more variables: lat <dbl>, long <dbl>
```

# Get ringbauer measures

This takes a network and a categorical node variable and calculate the
intra- and inter- level density.

## Usage

``` r
get_ringbauer_measures(g, grp)
```

## Arguments

- g:

  igraph object

- grp:

  a name of a categorical node variable

## Value

tibble with density measures

## Examples

``` r
get_ringbauer_measures(example_network, "site")
#> # A tibble: 9 × 8
#>   grp1  grp2  n_edges    n1    n2 n_possible_edges density label 
#>   <chr> <chr>   <dbl> <dbl> <dbl>            <dbl>   <dbl> <glue>
#> 1 A     A          15    14    14               91  0.165  15/91 
#> 2 A     C          15    14    14              196  0.0765 15/196
#> 3 A     B           8    14    12              168  0.0476 8/168 
#> 4 C     A          15    14    14              196  0.0765 15/196
#> 5 C     C          46    14    14               91  0.505  46/91 
#> 6 C     B           9    14    12              168  0.0536 9/168 
#> 7 B     A           8    12    14              168  0.0476 8/168 
#> 8 B     C           9    12    14              168  0.0536 9/168 
#> 9 B     B          18    12    12               66  0.273  18/66 
```

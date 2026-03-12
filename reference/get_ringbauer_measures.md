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
#> # A tibble: 9 × 10
#>   grp1  grp2  n_edges    n1    n2 n_possible_edges density label        pv
#>   <chr> <chr>   <dbl> <dbl> <dbl>            <dbl>   <dbl> <glue>    <dbl>
#> 1 C     C          38    12    12               66  0.576  38/66  3.32e-21
#> 2 C     B           8    12    13              156  0.0513 8/156  7.41e- 4
#> 3 C     A          10    12    15              180  0.0556 10/180 5.01e- 4
#> 4 B     C           8    13    12              156  0.0513 8/156  7.41e- 4
#> 5 B     B          21    13    13               78  0.269  21/78  5.98e- 3
#> 6 B     A          22    13    15              195  0.113  22/195 1.62e- 1
#> 7 A     C          10    15    12              180  0.0556 10/180 5.01e- 4
#> 8 A     B          22    15    13              195  0.113  22/195 1.62e- 1
#> 9 A     A          19    15    15              105  0.181  19/105 4.76e- 1
#> # ℹ 1 more variable: adj_pv <dbl>
```

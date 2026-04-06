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
#> # A tibble: 9 × 11
#>   grp1  grp2  n_edges    n1    n2 n_possible_edges density label overall_density
#>   <chr> <chr>   <dbl> <dbl> <dbl>            <dbl>   <dbl> <glu>           <dbl>
#> 1 A     A          17    16    16              120  0.142  17/1…           0.141
#> 2 A     B          14    16    12              192  0.0729 14/1…           0.141
#> 3 A     C          15    16    12              192  0.0781 15/1…           0.141
#> 4 B     A          14    12    16              192  0.0729 14/1…           0.141
#> 5 B     B          18    12    12               66  0.273  18/66           0.141
#> 6 B     C          14    12    12              144  0.0972 14/1…           0.141
#> 7 C     A          15    12    16              192  0.0781 15/1…           0.141
#> 8 C     B          14    12    12              144  0.0972 14/1…           0.141
#> 9 C     C          32    12    12               66  0.485  32/66           0.141
#> # ℹ 2 more variables: pv <dbl>, adj_pv <dbl>
```

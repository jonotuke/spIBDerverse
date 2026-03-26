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
#> 1 C     C          18    10    10               45  0.4    18/45           0.127
#> 2 C     A          11    10    17              170  0.0647 11/1…           0.127
#> 3 C     B           9    10    13              130  0.0692 9/130           0.127
#> 4 A     C          11    17    10              170  0.0647 11/1…           0.127
#> 5 A     A          20    17    17              136  0.147  20/1…           0.127
#> 6 A     B          20    17    13              221  0.0905 20/2…           0.127
#> 7 B     C           9    13    10              130  0.0692 9/130           0.127
#> 8 B     A          20    13    17              221  0.0905 20/2…           0.127
#> 9 B     B          21    13    13               78  0.269  21/78           0.127
#> # ℹ 2 more variables: pv <dbl>, adj_pv <dbl>
```

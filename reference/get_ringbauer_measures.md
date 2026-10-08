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
#> Warning: Chi-squared approximation may be incorrect
#> # A tibble: 9 × 11
#>   grp1  grp2  n_edges    n1    n2 n_possible_edges density label overall_density
#>   <chr> <chr>   <dbl> <dbl> <dbl>            <dbl>   <dbl> <glu>           <dbl>
#> 1 A     A          13    16    16              120  0.108  13/1…           0.133
#> 2 A     C          12    16    15              240  0.05   12/2…           0.133
#> 3 A     B           8    16     9              144  0.0556 8/144           0.133
#> 4 C     A          12    15    16              240  0.05   12/2…           0.133
#> 5 C     C          50    15    15              105  0.476  50/1…           0.133
#> 6 C     B           9    15     9              135  0.0667 9/135           0.133
#> 7 B     A           8     9    16              144  0.0556 8/144           0.133
#> 8 B     C           9     9    15              135  0.0667 9/135           0.133
#> 9 B     B          12     9     9               36  0.333  12/36           0.133
#> # ℹ 2 more variables: pv <dbl>, adj_pv <dbl>
```

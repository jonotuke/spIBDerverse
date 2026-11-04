# Get ringbauer measures

Takes a network and a categorical node variable and calculates the
intra- and inter-level edge density for every pair of levels. Each
density is compared with the overall network density using a one-sample
proportion test, with FDR-adjusted p-values. The 95% confidence interval
for each density (from the same
[`prop.test()`](https://rdrr.io/r/stats/prop.test.html) call) is
returned as `lwr` and `upr`.

## Usage

``` r
get_ringbauer_measures(g, grp)
```

## Arguments

- g:

  igraph object with a `name` vertex attribute

- grp:

  a name of a categorical node variable

## Value

tibble with one row per ordered pair of levels (`grp1`, `grp2`) and
columns `n_edges`, `n1`, `n2`, `n_possible_edges`, `density`, `label`,
`overall_density`, `lwr`, `upr`, `pv` and `adj_pv`

## Details

Nodes with a missing value of `grp` are dropped, along with their edges.
The network is treated as undirected.

## Examples

``` r
get_ringbauer_measures(example_network, "site")
#> # A tibble: 9 × 13
#>   grp1  grp2  n_edges    n1    n2 n_possible_edges density label overall_density
#>   <chr> <chr>   <dbl> <dbl> <dbl>            <dbl>   <dbl> <glu>           <dbl>
#> 1 C     C          55    15    15              105  0.524  55/1…           0.158
#> 2 C     B          18    15    11              165  0.109  18/1…           0.158
#> 3 C     A          14    15    14              210  0.0667 14/2…           0.158
#> 4 B     C          18    11    15              165  0.109  18/1…           0.158
#> 5 B     B          18    11    11               55  0.327  18/55           0.158
#> 6 B     A           7    11    14              154  0.0455 7/154           0.158
#> 7 A     C          14    14    15              210  0.0667 14/2…           0.158
#> 8 A     B           7    14    11              154  0.0455 7/154           0.158
#> 9 A     A          11    14    14               91  0.121  11/91           0.158
#> # ℹ 4 more variables: lwr <dbl>, upr <dbl>, pv <dbl>, adj_pv <dbl>
```

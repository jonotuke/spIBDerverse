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
#> 1 C     C          55    15    15              105  0.524  55/1…           0.172
#> 2 C     B          18    15    12              180  0.1    18/1…           0.172
#> 3 C     A          11    15    13              195  0.0564 11/1…           0.172
#> 4 B     C          18    12    15              180  0.1    18/1…           0.172
#> 5 B     B          22    12    12               66  0.333  22/66           0.172
#> 6 B     A          14    12    13              156  0.0897 14/1…           0.172
#> 7 A     C          11    13    15              195  0.0564 11/1…           0.172
#> 8 A     B          14    13    12              156  0.0897 14/1…           0.172
#> 9 A     A          14    13    13               78  0.179  14/78           0.172
#> # ℹ 4 more variables: lwr <dbl>, upr <dbl>, pv <dbl>, adj_pv <dbl>
```

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
#> 1 A     A          21    14    14               91  0.231  21/91           0.171
#> 2 A     B          17    14    12              168  0.101  17/1…           0.171
#> 3 A     C          18    14    14              196  0.0918 18/1…           0.171
#> 4 B     A          17    12    14              168  0.101  17/1…           0.171
#> 5 B     B          24    12    12               66  0.364  24/66           0.171
#> 6 B     C          11    12    14              168  0.0655 11/1…           0.171
#> 7 C     A          18    14    14              196  0.0918 18/1…           0.171
#> 8 C     B          11    14    12              168  0.0655 11/1…           0.171
#> 9 C     C          42    14    14               91  0.462  42/91           0.171
#> # ℹ 4 more variables: lwr <dbl>, upr <dbl>, pv <dbl>, adj_pv <dbl>
```

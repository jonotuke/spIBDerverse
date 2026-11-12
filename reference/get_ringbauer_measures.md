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
#> 1 B     B          32    15    15              105  0.305  32/1…           0.147
#> 2 B     C          13    15    14              210  0.0619 13/2…           0.147
#> 3 B     A           8    15    11              165  0.0485 8/165           0.147
#> 4 C     B          13    14    15              210  0.0619 13/2…           0.147
#> 5 C     C          42    14    14               91  0.462  42/91           0.147
#> 6 C     A          15    14    11              154  0.0974 15/1…           0.147
#> 7 A     B           8    11    15              165  0.0485 8/165           0.147
#> 8 A     C          15    11    14              154  0.0974 15/1…           0.147
#> 9 A     A           5    11    11               55  0.0909 5/55            0.147
#> # ℹ 4 more variables: lwr <dbl>, upr <dbl>, pv <dbl>, adj_pv <dbl>
```

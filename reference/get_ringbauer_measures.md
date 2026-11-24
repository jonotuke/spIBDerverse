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
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `prop_test = purrr::map2(...)`.
#> Caused by warning in `stats::prop.test()`:
#> ! Chi-squared approximation may be incorrect
#> # A tibble: 9 × 13
#>   grp1  grp2  n_edges    n1    n2 n_possible_edges density label overall_density
#>   <chr> <chr>   <dbl> <dbl> <dbl>            <dbl>   <dbl> <glu>           <dbl>
#> 1 A     A          35    19    19              171  0.205  35/1…           0.131
#> 2 A     B          16    19    13              247  0.0648 16/2…           0.131
#> 3 A     C           9    19     8              152  0.0592 9/152           0.131
#> 4 B     A          16    13    19              247  0.0648 16/2…           0.131
#> 5 B     B          22    13    13               78  0.282  22/78           0.131
#> 6 B     C           5    13     8              104  0.0481 5/104           0.131
#> 7 C     A           9     8    19              152  0.0592 9/152           0.131
#> 8 C     B           5     8    13              104  0.0481 5/104           0.131
#> 9 C     C          15     8     8               28  0.536  15/28           0.131
#> # ℹ 4 more variables: lwr <dbl>, upr <dbl>, pv <dbl>, adj_pv <dbl>
```

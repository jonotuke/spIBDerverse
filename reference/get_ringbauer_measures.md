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
get_ringbauer_measures(g, grp, refs = NULL)
```

## Arguments

- g:

  igraph object with a `name` vertex attribute

- grp:

  a name of a categorical node variable

- refs:

  reference level

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
```

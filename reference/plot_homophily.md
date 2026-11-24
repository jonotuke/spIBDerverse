# Plot homophily

Plots the mean connectivity (density) of each edge type, with a dashed
reference line at the overall network density.

## Usage

``` r
plot_homophily(
  RM,
  show_sign = FALSE,
  filter_sign = FALSE,
  sig_level = 0.05,
  ci = FALSE
)
```

## Arguments

- RM:

  A tibble of Ringbauer measures, as returned by
  [`get_ringbauer_measures()`](https://jonotuke.github.io/spIBDerverse/reference/get_ringbauer_measures.md).

- show_sign:

  Logical. If `TRUE`, colour points by significance instead of by
  within/between-group edge type.

- filter_sign:

  Logical. If `TRUE`, fade out non-significant edges.

- sig_level:

  Significance threshold applied to the adjusted p-values.

- ci:

  Logical. If `TRUE`, add 95% CI error bars for the proportions
  (requires `lwr` and `upr` columns in `RM`).

## Value

A ggplot object.

## Examples

``` r
get_ringbauer_measures(example_network, "site") |> plot_homophily()
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `prop_test = purrr::map2(...)`.
#> Caused by warning in `stats::prop.test()`:
#> ! Chi-squared approximation may be incorrect
```

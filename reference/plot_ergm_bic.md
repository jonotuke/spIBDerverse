# Plots BIC

Final version is based on BR's version

Final version is based on BR's version

## Usage

``` r
plot_ergm_bic(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
)

plot_ergm_bic(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
)
```

## Arguments

- ergms:

  a list of ergms

- text_size:

  size of x axis text

- text_angle:

  angle of x-axis text

- abbr:

  boolean to clean up names

- measure:

  decide if AIC or BIC.

- top_5:

  boolean to show just top 5 models

## Value

plot

plot

## Examples

``` r
ergms <- example_network |>
  fit_ergms(
    preds = c("site", "genetic_sex"),
    types = c("nodematch", "nodemix"))
plot_ergm_bic(ergms) |> print()

ergms <- example_network |>
  fit_ergms(
    preds = c("site", "genetic_sex"),
    types = c("nodematch", "nodemix"))
plot_ergm_bic(ergms) |> print()
```

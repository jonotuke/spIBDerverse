# Plot ergm coefficients

Plot ergm coefficients

## Usage

``` r
plot_ergm_coef(ergms, type = "theta", trim = TRUE, models = NULL)
```

## Arguments

- ergms:

  list of ergm fits

- type:

  either "theta" or "phi" - fold changes

- trim:

  remove -Inf coefficients

- models:

  models to show

## Value

plot of coefficients

## Examples

``` r
ergms <- fit_ergms(
  example_network,
  preds = c("site", "genetic_sex"),
  types = c("nodematch", "nodemix")
)
ergms |> plot_ergm_coef()
#> NULL
```

# Plot single ergm coefficients

Plot single ergm coefficients

## Usage

``` r
plot_single_ergm_coef(ergm, type = "theta", trim = TRUE)
```

## Arguments

- ergm:

  ergm model

- type:

  either "theta" or "phi" - fold changes

- trim:

  remove -Inf coefficients

## Value

plot of coefficients

## Examples

``` r
ergms <- fit_ergms(
  example_network,
  preds = c("site", "genetic_sex"),
  types = c("nodematch", "nodemix")
)
ergms[[1]] |> plot_single_ergm_coef()
```

# Tab ergm coefficients

Tab ergm coefficients

## Usage

``` r
tab_ergm_coef(ergms, models = NULL)
```

## Arguments

- ergms:

  list of ergm fits

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

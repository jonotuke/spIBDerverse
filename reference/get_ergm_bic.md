# Tabulate the ergm AIC and BIC

Tabulate the ergm AIC and BIC

## Usage

``` r
get_ergm_bic(ergms)
```

## Arguments

- ergms:

  list of ergm fits

## Value

tibble of AIC and BIC for each model

## Examples

``` r
ergms <- fit_ergms(
  example_network,
  preds = c("site", "genetic_sex"),
  types = c("nodematch", "nodemix")
)
ergms |> get_ergm_bic()
#> # A tibble: 4 × 3
#>   Model                                                          AIC   BIC
#>   <chr>                                                        <dbl> <dbl>
#> 1 network ~ edges + nodematch('site') + nodemix('genetic_sex')  528.  547.
#> 2 network ~ edges + nodematch('site')                           580.  589.
#> 3 network ~ edges + nodemix('genetic_sex')                      610.  624.
#> 4 network ~ edges                                               654.  659.
```

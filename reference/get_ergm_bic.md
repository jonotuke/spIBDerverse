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
ergms <- get_ergms(
  example_network,
  preds = c("site", "genetic_sex"),
  types = c("nodematch", "nodemix")
)
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
ergms |> get_ergm_bic()
#> # A tibble: 4 × 3
#>   Model                                                          AIC   BIC
#>   <chr>                                                        <dbl> <dbl>
#> 1 network ~ edges + nodematch('site') + nodemix('genetic_sex')  549.  567.
#> 2 network ~ edges + nodematch('site')                           597.  607.
#> 3 network ~ edges + nodemix('genetic_sex')                      619.  633.
#> 4 network ~ edges                                               665.  670.
```

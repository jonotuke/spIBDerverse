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
  preds = c("site", "genetic_sex")
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
#>   Model                                                        AIC   BIC
#>   <chr>                                                      <dbl> <dbl>
#> 1 network ~ edges + nodemix('site') + nodemix('genetic_sex')  467.  504.
#> 2 network ~ edges + nodemix('site')                           537.  565.
#> 3 network ~ edges + nodemix('genetic_sex')                    578.  592.
#> 4 network ~ edges                                             640.  645.
```

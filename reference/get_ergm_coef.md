# Gets coefficients and fold changes for a ergm model

Gets coefficients and fold changes for a ergm model

## Usage

``` r
get_ergm_coef(ergm)
```

## Arguments

- ergm:

  ergm model

## Value

coefficient table

## Examples

``` r
ergms <- get_ergms(
example_network,
preds = c("site", "genetic_sex"),
types = c("nodematch", "nodematch")
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
ergms[[1]] |> get_ergm_coef()
#> # A tibble: 2 × 6
#>   term            coef fold_change std.error statistic  p.value
#>   <chr>          <dbl>       <dbl>     <dbl>     <dbl>    <dbl>
#> 1 edges          -2.43        1        0.159    -15.3  1.21e-52
#> 2 nodematch.site  1.88        4.51     0.206      9.09 9.59e-20
```

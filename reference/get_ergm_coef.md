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
#> 1 edges          -2.51        1        0.164    -15.3  1.64e-52
#> 2 nodematch.site  1.72        4.16     0.214      8.06 7.78e-16
```

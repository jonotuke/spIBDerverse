# Convert ergm coefficients to fold changes

The fold changes are all based on comparison to reference level

## Usage

``` r
get_ergm_fc(ergm, trim = TRUE)
```

## Arguments

- ergm:

  an ergm fit

- trim:

  whether to remove coefficients where the coefficient is -Inf

## Value

tibble of fold changes

## Examples

``` r
ergm <- get_ergms(example_network, preds = "site", types = "nodemix")
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
get_ergm_fc(ergm[[1]])
#> # A tibble: 6 × 3
#>   term          theta   phi
#>   <chr>         <dbl> <dbl>
#> 1 edges        -1.20  1    
#> 2 mix.site.A.B -0.980 0.438
#> 3 mix.site.B.B  0.644 1.58 
#> 4 mix.site.A.C -1.09  0.398
#> 5 mix.site.B.C -1.45  0.284
#> 6 mix.site.C.C  1.05  2.00 
```

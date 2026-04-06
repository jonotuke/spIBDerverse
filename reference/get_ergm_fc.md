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
#> 1 edges        -1.80  1    
#> 2 mix.site.A.B -0.741 0.515
#> 3 mix.site.B.B  0.821 1.93 
#> 4 mix.site.A.C -0.667 0.551
#> 5 mix.site.B.C -0.427 0.686
#> 6 mix.site.C.C  1.74  3.42 
```

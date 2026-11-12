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
ergm <- fit_ergms(example_network, preds = "site", types = "nodemix")
get_ergm_fc(ergm[[1]])
#> # A tibble: 6 × 3
#>   term           theta   phi
#>   <chr>          <dbl> <dbl>
#> 1 edges        -2.30   1    
#> 2 mix.site.A.B -0.674  0.533
#> 3 mix.site.B.B  1.48   3.35 
#> 4 mix.site.A.C  0.0762 1.07 
#> 5 mix.site.B.C -0.416  0.681
#> 6 mix.site.C.C  2.15   5.08 
```

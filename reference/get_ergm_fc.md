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
#>   term          theta   phi
#>   <chr>         <dbl> <dbl>
#> 1 edges        -1.36  1    
#> 2 mix.site.A.B -1.31  0.316
#> 3 mix.site.B.B  0.423 1.38 
#> 4 mix.site.A.C -1.41  0.289
#> 5 mix.site.B.C -1.63  0.235
#> 6 mix.site.C.C  1.50  2.62 
```

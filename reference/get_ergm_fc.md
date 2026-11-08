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
get_ergm_fc(ergm[[1]])
#> # A tibble: 6 × 3
#>   term          theta   phi
#>   <chr>         <dbl> <dbl>
#> 1 edges        -1.52  1    
#> 2 mix.site.A.B -0.797 0.5  
#> 3 mix.site.B.B  0.827 1.86 
#> 4 mix.site.A.C -1.30  0.314
#> 5 mix.site.B.C -0.677 0.557
#> 6 mix.site.C.C  1.62  2.92 
```

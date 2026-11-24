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
ergms <- fit_ergms(
example_network,
preds = c("site", "genetic_sex"),
types = c("nodematch", "nodematch")
)
ergms[[1]] |> get_ergm_coef()
#> # A tibble: 2 × 6
#>   term            coef fold_change std.error statistic  p.value
#>   <chr>          <dbl>       <dbl>     <dbl>     <dbl>    <dbl>
#> 1 edges          -2.76        1        0.188    -14.6  1.38e-48
#> 2 nodematch.site  1.71        4.36     0.233      7.35 1.97e-13
```

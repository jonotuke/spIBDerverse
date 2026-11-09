# Predicts probability for an edge for given distances

Predicts probability for an edge for given distances

## Usage

``` r
predict_spatial_ergm(fit, N, level = 0.95, N_cov = 100)
```

## Arguments

- fit:

  a model from the ERGM package which must have the distance as a
  predictor

- N:

  the grid density of the fitted distance

- level:

  the confidence level for the error bars

- N_cov:

  number of evenly spaced values to predict over for each `nodecov()`
  term. A `nodecov()` term for a dyad is the sum of the two nodes'
  attribute values, so the sequence runs from the smallest to the
  largest observed sum and is returned in a column named
  `<attribute>_sum`.

## Value

tibble of predicted values

## Examples

``` r
fit_spatial_ergm(example_network, "lat", "long", "site") |>
 predict_spatial_ergm(N = 100)
#> # A tibble: 600 × 6
#>    site   dist     p se_logit lower upper
#>    <chr> <dbl> <dbl>    <dbl> <dbl> <dbl>
#>  1 C/C   0     0.525    0.196 0.430 0.619
#>  2 C/C   0.140 0.525    0.196 0.429 0.618
#>  3 C/C   0.279 0.524    0.196 0.429 0.618
#>  4 C/C   0.419 0.524    0.195 0.429 0.618
#>  5 C/C   0.558 0.524    0.195 0.428 0.617
#>  6 C/C   0.698 0.523    0.196 0.428 0.617
#>  7 C/C   0.837 0.523    0.196 0.427 0.617
#>  8 C/C   0.977 0.522    0.196 0.427 0.616
#>  9 C/C   1.12  0.522    0.196 0.426 0.616
#> 10 C/C   1.26  0.522    0.197 0.426 0.616
#> # ℹ 590 more rows
```

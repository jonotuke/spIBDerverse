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
#>  1 A/A   0     0.262    0.138 0.213 0.317
#>  2 A/A   0.137 0.261    0.137 0.213 0.316
#>  3 A/A   0.274 0.261    0.137 0.212 0.316
#>  4 A/A   0.410 0.260    0.137 0.212 0.315
#>  5 A/A   0.547 0.260    0.137 0.211 0.315
#>  6 A/A   0.684 0.259    0.137 0.211 0.314
#>  7 A/A   0.821 0.259    0.137 0.210 0.314
#>  8 A/A   0.957 0.258    0.138 0.210 0.313
#>  9 A/A   1.09  0.258    0.138 0.209 0.313
#> 10 A/A   1.23  0.257    0.139 0.209 0.313
#> # ℹ 590 more rows
```

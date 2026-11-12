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
#>    site   dist      p se_logit  lower  upper
#>    <chr> <dbl>  <dbl>    <dbl>  <dbl>  <dbl>
#>  1 B/C   0     0.0436    0.412 0.0199 0.0926
#>  2 B/C   0.138 0.0438    0.407 0.0202 0.0924
#>  3 B/C   0.276 0.0441    0.403 0.0205 0.0923
#>  4 B/C   0.414 0.0444    0.398 0.0209 0.0921
#>  5 B/C   0.552 0.0447    0.393 0.0212 0.0919
#>  6 B/C   0.690 0.0450    0.389 0.0215 0.0917
#>  7 B/C   0.828 0.0453    0.384 0.0219 0.0915
#>  8 B/C   0.966 0.0456    0.380 0.0222 0.0913
#>  9 B/C   1.10  0.0459    0.375 0.0225 0.0912
#> 10 B/C   1.24  0.0462    0.371 0.0229 0.0910
#> # ℹ 590 more rows
```

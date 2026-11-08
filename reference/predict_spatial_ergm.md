# Predicts probability for an edge for given distances

Predicts probability for an edge for given distances

## Usage

``` r
predict_spatial_ergm(fit, N, level = 0.95, distance_term = NULL)
```

## Arguments

- fit:

  a model from the ERGM package which must have the distance as a
  predictor

- N:

  the grid density of the fitted distance

- level:

  the confidence level for the error bars

- distance_term:

  name for the distance variable

## Value

tibble of predicted values

## Examples

``` r
fit_spatial_ergm(example_network, "lat", "long", "site")$model[[1]] |>
 predict_spatial_ergm(N = 100)
#> # A tibble: 100 × 5
#>    distance     p se_logit lower upper
#>       <dbl> <dbl>    <dbl> <dbl> <dbl>
#>  1    0     0.285    0.122 0.239 0.336
#>  2    0.140 0.281    0.120 0.236 0.331
#>  3    0.279 0.277    0.119 0.233 0.326
#>  4    0.419 0.274    0.117 0.231 0.322
#>  5    0.558 0.270    0.116 0.228 0.317
#>  6    0.698 0.267    0.114 0.225 0.313
#>  7    0.837 0.263    0.113 0.222 0.308
#>  8    0.977 0.260    0.111 0.220 0.304
#>  9    1.12  0.256    0.110 0.217 0.299
#> 10    1.26  0.253    0.109 0.214 0.295
#> # ℹ 90 more rows
```

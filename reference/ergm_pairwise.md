# Get pairwise differences for a categorical predictor in an ergm model

Get pairwise differences for a categorical predictor in an ergm model

## Usage

``` r
ergm_pairwise(ergm_model, term_string, max_cells = 50)
```

## Arguments

- ergm_model:

  fitted ermg model

- term_string:

  pred to perform pairwise on

- max_cells:

  limit on number of comparisons

## Value

pairwise tibble

## Examples

``` r
ergms <- fit_ergms(example_network, "site", "nodemix")
ergm_pairwise(ergms[[1]], "site")
#> # A tibble: 15 × 7
#>    contrast  odds.ratio     SE    df  null z.ratio   p.value
#>    <fct>          <dbl>  <dbl> <dbl> <dbl>   <dbl>     <dbl>
#>  1 A.A / A.B     1.96   1.16     Inf     1   1.14  8.66 e- 1
#>  2 A.A / A.C     0.927  0.502    Inf     1  -0.140 1.000e+ 0
#>  3 A.A / B.B     0.228  0.117    Inf     1  -2.87  4.71 e- 2
#>  4 A.A / B.C     1.52   0.833    Inf     1   0.756 9.75 e- 1
#>  5 A.A / C.C     0.117  0.0600   Inf     1  -4.18  4.19 e- 4
#>  6 A.B / A.C     0.472  0.214    Inf     1  -1.66  5.61 e- 1
#>  7 A.B / B.B     0.116  0.0488   Inf     1  -5.13  4.42 e- 6
#>  8 A.B / B.C     0.772  0.357    Inf     1  -0.560 9.94 e- 1
#>  9 A.B / C.C     0.0594 0.0249   Inf     1  -6.74  2.44 e-10
#> 10 A.C / B.B     0.246  0.0849   Inf     1  -4.07  6.79 e- 4
#> 11 A.C / B.C     1.64   0.646    Inf     1   1.25  8.14 e- 1
#> 12 A.C / C.C     0.126  0.0433   Inf     1  -6.03  2.45 e- 8
#> 13 B.B / B.C     6.64   2.37     Inf     1   5.31  1.59 e- 6
#> 14 B.B / C.C     0.511  0.153    Inf     1  -2.25  2.17 e- 1
#> 15 B.C / C.C     0.0770 0.0274   Inf     1  -7.22  7.99 e-12
```

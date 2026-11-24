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
#>    contrast  odds.ratio     SE    df  null z.ratio      p.value
#>    <fct>          <dbl>  <dbl> <dbl> <dbl>   <dbl>        <dbl>
#>  1 A.A / A.B     3.72   1.19     Inf     1   4.09  0.000603    
#>  2 A.A / A.C     4.09   1.60     Inf     1   3.59  0.00449     
#>  3 A.A / B.B     0.655  0.206    Inf     1  -1.34  0.761       
#>  4 A.A / B.C     5.10   2.53     Inf     1   3.28  0.0131      
#>  5 A.A / C.C     0.223  0.0945   Inf     1  -3.54  0.00534     
#>  6 A.B / A.C     1.10   0.473    Inf     1   0.223 1.000       
#>  7 A.B / B.B     0.176  0.0636   Inf     1  -4.81  0.0000222   
#>  8 A.B / B.C     1.37   0.722    Inf     1   0.600 0.991       
#>  9 A.B / C.C     0.0600 0.0275   Inf     1  -6.13  0.0000000130
#> 10 A.C / B.B     0.160  0.0682   Inf     1  -4.30  0.000247    
#> 11 A.C / B.C     1.25   0.714    Inf     1   0.384 0.999       
#> 12 A.C / C.C     0.0545 0.0279   Inf     1  -5.69  0.000000195 
#> 13 B.B / B.C     7.78   4.07     Inf     1   3.92  0.00123     
#> 14 B.B / C.C     0.340  0.155    Inf     1  -2.37  0.167       
#> 15 B.C / C.C     0.0438 0.0260   Inf     1  -5.26  0.00000213  
```

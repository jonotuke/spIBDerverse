# get_all_models

this function returns all possible models with the outcome variable y,
and the predictors preds.

## Usage

``` r
get_all_models(preds, y, constant = "edges")
```

## Arguments

- preds:

  vector of igraph attributes

- y:

  outcome variable

- constant:

  constant term

## Value

a vector of strings of linear models

## Examples

``` r
get_all_models(c("X1", "X2"), "y", "1")
#> [[1]]
#> y ~ 1 + X1
#> 
#> [[2]]
#> y ~ 1 + X2
#> 
#> [[3]]
#> y ~ 1 + X1 + X2
#> 
#> [[4]]
#> y ~ 1
#> 
```

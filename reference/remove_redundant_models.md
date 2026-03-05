# remove redundant models

remove redundant models

## Usage

``` r
remove_redundant_models(models, vars)
```

## Arguments

- models:

  list of models

- vars:

  list of variables to filter on

## Value

list so each var appears only once

## Examples

``` r
M1 <- "network ~ edges + nodematch('A') + nodemix('A')"
M2 <- "network ~ edges + nodematch('A')"
remove_redundant_models(list(M1, M2), "A")
#> [[1]]
#> [1] "network ~ edges + nodematch('A')"
#> 
```

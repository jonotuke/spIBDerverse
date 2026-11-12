# fit_ergms

Given node attributes and a network, fits all possible ergms. Nodes with
missing values in any of `preds` are removed first (see
[`drop_missing_nodes()`](https://jonotuke.github.io/spIBDerverse/reference/drop_missing_nodes.md)),
and all models are fitted to the same reduced network so they remain
comparable.

## Usage

``` r
fit_ergms(network, preds = NULL, types = NULL)
```

## Arguments

- network:

  igraph object

- preds:

  vector of predictors

- types:

  vector of ergm term types

## Value

list of ergm models. The removed vertices are stored in
`attr(result, "removed_nodes")`.

## Examples

``` r
fit_ergms(example_network, c("site", "genetic_sex"), c("nodematch", "nodemix"))
#> $`network ~ edges + nodematch('site')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>          edges  nodematch.site  
#>         -2.617           1.839  
#> 
#> $`network ~ edges + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges  mix.genetic_sex.F.M  mix.genetic_sex.M.M  
#>              -1.286               -1.411                0.248  
#> 
#> $`network ~ edges + nodematch('site') + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges       nodematch.site  mix.genetic_sex.F.M  
#>             -2.1860               2.0117              -1.5775  
#> mix.genetic_sex.M.M  
#>              0.3276  
#> 
#> $`network ~ edges`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>  edges  
#> -1.755  
#> 
#> attr(,"removed_nodes")
#> character(0)
```

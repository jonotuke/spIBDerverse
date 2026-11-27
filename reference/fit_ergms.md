# fit_ergms

Given node attributes and a network, fits all possible ergms. Nodes with
missing values in any of `preds` are removed first (see
[`drop_missing_nodes()`](https://jonotuke.github.io/spIBDerverse/reference/drop_missing_nodes.md)),
and all models are fitted to the same reduced network so they remain
comparable.

## Usage

``` r
fit_ergms(network, preds = NULL, types = NULL, refs = NULL, progress = TRUE)
```

## Arguments

- network:

  igraph object

- preds:

  vector of predictors

- types:

  vector of ergm term types

- refs:

  named list (names = predictors) of the one or two levels whose nodemix
  cell should be the reference. `NULL` entries, or missing predictors,
  use ergm's default (first cell dropped).

- progress:

  `TRUE` (default) for a cli progress bar in the console, `FALSE` for
  none, or a function called as `progress(i, n, model)` after each model
  is fitted (e.g. to drive a shiny progress bar).

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
#>         -2.758           1.712  
#> 
#> $`network ~ edges + nodemix('genetic_sex', levels2 = -1)`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges  mix.genetic_sex.F.M  mix.genetic_sex.M.M  
#>             -1.5506              -0.9542               0.0902  
#> 
#> $`network ~ edges + nodematch('site') + nodemix('genetic_sex', levels2 = -1)`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges       nodematch.site  mix.genetic_sex.F.M  
#>            -2.38471              1.79328             -1.10163  
#> mix.genetic_sex.M.M  
#>             0.06387  
#> 
#> $`network ~ edges`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>  edges  
#> -1.894  
#> 
#> attr(,"removed_nodes")
#> character(0)
```

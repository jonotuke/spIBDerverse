# get_ergms

Given node attributes and a network, fits all possible ergms. Nodes with
missing values in any of `preds` are removed first (see
[`drop_missing_nodes()`](https://jonotuke.github.io/spIBDerverse/reference/drop_missing_nodes.md)),
and all models are fitted to the same reduced network so they remain
comparable.

## Usage

``` r
get_ergms(network, preds = NULL, types = NULL)
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
get_ergms(example_network, c("site", "genetic_sex"), c("nodematch", "nodemix"))
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> Starting maximum pseudolikelihood estimation (MPLE):
#> Obtaining the responsible dyads.
#> Evaluating the predictor and response matrix.
#> Maximizing the pseudolikelihood.
#> Finished MPLE.
#> Evaluating log-likelihood at the estimate. 
#> 
#> $`network ~ edges + nodematch('site')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>          edges  nodematch.site  
#>         -2.358           1.742  
#> 
#> $`network ~ edges + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges  mix.genetic_sex.F.M  mix.genetic_sex.M.M  
#>            -0.92799             -1.78006             -0.05783  
#> 
#> $`network ~ edges + nodematch('site') + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges       nodematch.site  mix.genetic_sex.F.M  
#>             -1.6759               1.9848              -2.0786  
#> mix.genetic_sex.M.M  
#>             -0.1179  
#> 
#> $`network ~ edges`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>  edges  
#> -1.582  
#> 
#> attr(,"removed_nodes")
#> character(0)
```

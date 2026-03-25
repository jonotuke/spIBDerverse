# get_ergms

Given node attributes and a network, fits all possible ergms

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

list of ergm models

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
#>         -2.487           1.266  
#> 
#> $`network ~ edges + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges  mix.genetic_sex.F.M  mix.genetic_sex.M.M  
#>             -1.2669              -1.8801              -0.1387  
#> 
#> $`network ~ edges + nodematch('site') + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges       nodematch.site  mix.genetic_sex.F.M  
#>             -1.7962               1.3661              -2.0089  
#> mix.genetic_sex.M.M  
#>             -0.1987  
#> 
#> $`network ~ edges`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>  edges  
#> -1.928  
#> 
```

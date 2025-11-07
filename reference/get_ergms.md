# get_ergms

Given node attributes and a network, fits all possible ergms

## Usage

``` r
get_ergms(network, preds = NULL)
```

## Arguments

- network:

  igraph object

- preds:

  vector of predictors

## Value

list of ergm models

## Examples

``` r
get_ergms(example_network, c("site", "genetic_sex"))
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
#> $`network ~ edges + nodemix('site')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>        edges  mix.site.A.B  mix.site.B.B  mix.site.A.C  mix.site.B.C  
#>      -1.6227       -1.3730        0.6419       -0.8678       -1.2490  
#> mix.site.C.C  
#>       1.6447  
#> 
#> $`network ~ edges + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges  mix.genetic_sex.F.M  mix.genetic_sex.M.M  
#>            -1.11600             -1.92852             -0.06265  
#> 
#> $`network ~ edges + nodemix('site') + nodemix('genetic_sex')`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>               edges         mix.site.A.B         mix.site.B.B  
#>             -1.0214              -1.5870               0.6982  
#>        mix.site.A.C         mix.site.B.C         mix.site.C.C  
#>             -0.9532              -1.3154               1.9115  
#> mix.genetic_sex.F.M  mix.genetic_sex.M.M  
#>             -2.0704               0.3942  
#> 
#> $`network ~ edges`
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>  edges  
#> -1.796  
#> 
```

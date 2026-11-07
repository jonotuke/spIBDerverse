# Fit spatial ergm

Fits an ERGM model to look at the probability of an edge based on
spatial distance between nodes

## Usage

``` r
fit_spatial_ergm(g, lat, long, pred = NULL)
```

## Arguments

- g:

  igraph object

- lat:

  node attribute for lat

- long:

  node attribute for long

- pred:

  extra predictor for spatial relationship

## Value

lowest BIC model

## Examples

``` r
fit_spatial_ergm(example_network, "lat", "long", "site")
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
#> # A tibble: 4 × 3
#>   formula                                                 model    BIC
#>   <chr>                                                   <list> <dbl>
#> 1 g ~ edges + edgecov(D)                                  <ergm>  676.
#> 2 g ~ edges + edgecov(D) + nodemix('site')                <ergm>  645.
#> 3 g ~ edges + edgecov(D) + nodematch('site')              <ergm>  645.
#> 4 g ~ edges + edgecov(D) + nodematch('site', diff = TRUE) <ergm>  634.
```

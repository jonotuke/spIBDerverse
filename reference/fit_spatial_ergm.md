# Fit spatial ergm

Fits an ERGM model to look at the probability of an edge based on
spatial distance between nodes

## Usage

``` r
fit_spatial_ergm(g, lat, long, pred = "none")
```

## Arguments

- g:

  igraph object

- lat:

  node attribute for lat

- long:

  node attribute for long

- pred:

  node attribute for non-dist predictor. If the attribute is numeric
  (integer or double) it is fitted with `nodecov()`; otherwise it is
  treated as categorical and fitted with `nodematch()`/`nodemix()`.

## Value

lowest BIC model

## Examples

``` r
fit_spatial_ergm(example_network, "lat", "long", "site")
#> 
#> Call:
#> ergm::ergm(formula = stats::as.formula(x))
#> 
#> Maximum Likelihood Coefficients:
#>            edges         edgecov.D  nodematch.site.A  nodematch.site.B  
#>         -2.32044          -0.01203           0.80602           1.63435  
#> nodematch.site.C  
#>          2.42168  
```

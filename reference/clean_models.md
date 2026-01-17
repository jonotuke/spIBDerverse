# clean model names

clean model names

## Usage

``` r
clean_models(x)
```

## Arguments

- x:

  vector of ergm model names

## Value

cleaned vector

## Examples

``` r
ergms <- example_network |>
  get_ergms(c("site", "genetic_sex"), c("nodemix", "nodematch")) |>
  purrr::map(broom::glance) |>
  purrr::list_rbind(names_to = "model")
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
clean_models(ergms$model) |> print()
#> [1] "edges|NM(site)"                       
#> [2] "edges|nodematch(genetic_sex)"         
#> [3] "edges|NM(site)|nodematch(genetic_sex)"
#> [4] "edges"                                
```

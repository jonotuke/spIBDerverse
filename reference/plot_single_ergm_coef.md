# Plot single ergm coefficients

Plot single ergm coefficients

## Usage

``` r
plot_single_ergm_coef(ergm, type = "theta", trim = TRUE)
```

## Arguments

- ergm:

  ergm model

- type:

  either "theta" or "phi" - fold changes

- trim:

  remove -Inf coefficients

## Value

plot of coefficients

## Examples

``` r
ergms <- get_ergms(
  example_network,
  preds = c("site", "genetic_sex")
)
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
ergms[[1]] |> plot_single_ergm_coef()
```

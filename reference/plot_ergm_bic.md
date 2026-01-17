# plot_ergm_bic

For each ergm model plots the BIC

Final version is based on BR's version

## Usage

``` r
plot_ergm_bic(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
)

plot_ergm_bic(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
)
```

## Arguments

- ergms:

  a list of ergms

- text_size:

  size of x axis text

- text_angle:

  angle of x-axis text

- abbr:

  boolean to clean up names

- measure:

  decide if AIC or BIC.

- top_5:

  boolean to show just top 5 models

## Value

ggplot of BIC for each ergm

plot

## Examples

``` r
ergms <- get_ergms(
  example_network,
  preds = c("site", "genetic_sex"),
  types = c("nodematch", "nodemix")
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
ergms |> plot_ergm_bic()

ergms <- example_network |>
  get_ergms(
    preds = c("site", "genetic_sex"),
    types = c("nodematch", "nodemix"))
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
plot_ergm_bic(ergms) |> print()
```

# plot spatial ergm

plot spatial ergm

## Usage

``` r
plot_spatial_ergm(spatial_pred, pred = NULL)
```

## Arguments

- spatial_pred:

  predict tibble from spatial ergm

- pred:

  predictor to colour by

## Value

ggplot

## Examples

``` r
ergms <- fit_spatial_ergm(
example_network_5,
"Latitude",
"Longitude",
"period"
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
ergms$model[[3]] |>
 predict_spatial_ergm(N = 100) |>
 plot_spatial_ergm("period")
```

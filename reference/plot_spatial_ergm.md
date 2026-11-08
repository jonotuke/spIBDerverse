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
ergms$model[[3]] |>
 predict_spatial_ergm(N = 100) |>
 plot_spatial_ergm("period")
```

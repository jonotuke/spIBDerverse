# plot spatial ergm

plot spatial ergm

## Usage

``` r
plot_spatial_ergm(spatial_pred)
```

## Arguments

- spatial_pred:

  predict tibble from spatial ergm

## Value

ggplot. If the predictor is numeric (a `nodecov()` term) this is a tile
plot with distance on the x-axis, the predictor on the y-axis and fill
showing the probability of an edge; otherwise a line plot of probability
against distance with confidence ribbons.

## Examples

``` r
ergms <- fit_spatial_ergm(
example_network_5,
"Latitude",
"Longitude",
"period"
)
ergms |>
 predict_spatial_ergm(N = 100) |>
 plot_spatial_ergm()
```

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

ggplot

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

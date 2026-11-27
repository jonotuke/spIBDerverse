# plot spatial ergm

plot spatial ergm

## Usage

``` r
plot_spatial_ergm(spatial_pred, pal = "default", x_lim = NULL)
```

## Arguments

- spatial_pred:

  predict tibble from spatial ergm

- pal:

  palette

- x_lim:

  optional numeric vector of length 2 giving the distance (km) limits
  for the x-axis of the ribbon plot. If `NULL` (default) the full range
  of distances is shown.

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

# get lat or lon from network sf object

get lat or lon from network sf object

## Usage

``` r
get_lat_range(network_sf, type = "lat")
```

## Arguments

- network_sf:

  network sf object

- type:

  whether lat or lon

## Value

2 vector of lat or lon

## Examples

``` r
get_lat_range(example_sf, "lon")
#> [1] 138.4662 138.7445
get_lat_range(example_sf, "lat")
#> [1] -34.93942 -34.79425
```

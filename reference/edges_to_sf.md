# edges to sf

edges to sf

## Usage

``` r
edges_to_sf(graph, lat = "lat", lon = "long")
```

## Arguments

- graph:

  igraph obj

- lat:

  lat attribute

- lon:

  long attribute

## Value

sf edge object

## Examples

``` r
edges_to_sf(example_network)
#> Simple feature collection with 111 features and 3 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5867 ymin: -34.92707 xmax: 138.6253 ymax: -34.8057
#> CRS:           NA
#> First 10 features:
#>    from to       wij                       geometry
#> 1     1 27 0.2197758 LINESTRING (138.6034 -34.91...
#> 2     2  5 0.5106080 LINESTRING (138.6076 -34.91...
#> 3     2  7 0.3409132 LINESTRING (138.6076 -34.91...
#> 4     2 11 0.6788386 LINESTRING (138.6076 -34.91...
#> 5     2 12 0.2045953 LINESTRING (138.6076 -34.91...
#> 6     2 23 0.6381921 LINESTRING (138.6076 -34.91...
#> 7     2 34 0.7134420 LINESTRING (138.6076 -34.91...
#> 8     3  4 0.6843764 LINESTRING (138.6172 -34.80...
#> 9     3  5 0.6784361 LINESTRING (138.6172 -34.80...
#> 10    3  7 0.8005252 LINESTRING (138.6172 -34.80...
```

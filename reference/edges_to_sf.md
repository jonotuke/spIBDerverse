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
#> Simple feature collection with 104 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5872 ymin: -34.92712 xmax: 138.6249 ymax: -34.80462
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.8870518         C LINESTRING (138.6066 -34.91...
#> 2     1 13 0.1208347         A LINESTRING (138.6066 -34.91...
#> 3     1 19 0.8034147         A LINESTRING (138.6066 -34.91...
#> 4     1 26 0.6814461         A LINESTRING (138.6066 -34.91...
#> 5     1 30 0.2271457         A LINESTRING (138.6066 -34.91...
#> 6     1 31 0.8612543         A LINESTRING (138.6066 -34.91...
#> 7     2  6 0.4279519         A LINESTRING (138.6198 -34.81...
#> 8     2 10 0.4448979         B LINESTRING (138.6198 -34.81...
#> 9     2 22 0.8704754         B LINESTRING (138.6198 -34.81...
#> 10    2 23 0.6761962         A LINESTRING (138.6198 -34.81...
```

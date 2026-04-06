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
#> Simple feature collection with 110 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5881 ymin: -34.92651 xmax: 138.6244 ymax: -34.80677
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  9 0.5285331         C LINESTRING (138.6035 -34.91...
#> 2     1 13 0.2139032         C LINESTRING (138.6035 -34.91...
#> 3     1 14 0.8284278         C LINESTRING (138.6035 -34.91...
#> 4     1 15 0.2564991         C LINESTRING (138.6035 -34.91...
#> 5     1 17 0.3335371         C LINESTRING (138.6035 -34.91...
#> 6     1 19 0.7717315         C LINESTRING (138.6035 -34.91...
#> 7     1 20 0.2631826         C LINESTRING (138.6035 -34.91...
#> 8     1 25 0.7058799         C LINESTRING (138.6035 -34.91...
#> 9     1 28 0.4773074         B LINESTRING (138.6035 -34.91...
#> 10    2  5 0.8452066         A LINESTRING (138.6029 -34.91...
```

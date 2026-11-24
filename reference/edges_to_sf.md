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
#> Simple feature collection with 102 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.588 ymin: -34.9259 xmax: 138.6242 ymax: -34.80703
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  8 0.7950972         A LINESTRING (138.6027 -34.91...
#> 2     1 23 0.3773861         A LINESTRING (138.6027 -34.91...
#> 3     1 34 0.8931674         A LINESTRING (138.6027 -34.91...
#> 4     2 14 0.4023918         A LINESTRING (138.6037 -34.91...
#> 5     2 30 0.7422079         C LINESTRING (138.6037 -34.91...
#> 6     2 32 0.3574451         A LINESTRING (138.6037 -34.91...
#> 7     2 36 0.3582959         C LINESTRING (138.6037 -34.91...
#> 8     2 38 0.1332810         A LINESTRING (138.6037 -34.91...
#> 9     3 12 0.1275488         C LINESTRING (138.6078 -34.91...
#> 10    3 14 0.1636614         C LINESTRING (138.6078 -34.91...
```

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
#> Simple feature collection with 133 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5878 ymin: -34.92733 xmax: 138.6246 ymax: -34.80447
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.4105681         B LINESTRING (138.6028 -34.91...
#> 2     1 25 0.1825956         A LINESTRING (138.6028 -34.91...
#> 3     1 29 0.4240473         A LINESTRING (138.6028 -34.91...
#> 4     1 33 0.9754908         B LINESTRING (138.6028 -34.91...
#> 5     1 38 0.9277891         A LINESTRING (138.6028 -34.91...
#> 6     2  4 0.6772017         A LINESTRING (138.5878 -34.92...
#> 7     2  9 0.7726272         A LINESTRING (138.5878 -34.92...
#> 8     2 10 0.4193386         B LINESTRING (138.5878 -34.92...
#> 9     2 12 0.5715213         A LINESTRING (138.5878 -34.92...
#> 10    2 15 0.7370064         B LINESTRING (138.5878 -34.92...
```

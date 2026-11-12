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
#> Simple feature collection with 115 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5869 ymin: -34.9245 xmax: 138.6256 ymax: -34.80444
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.4652617         B LINESTRING (138.5938 -34.92...
#> 2     1 17 0.8738065         B LINESTRING (138.5938 -34.92...
#> 3     1 24 0.7746617         A LINESTRING (138.5938 -34.92...
#> 4     1 27 0.6882055         C LINESTRING (138.5938 -34.92...
#> 5     1 30 0.2656558         C LINESTRING (138.5938 -34.92...
#> 6     2  3 0.5596643         C LINESTRING (138.6252 -34.80...
#> 7     2  5 0.2687546         C LINESTRING (138.6252 -34.80...
#> 8     2  8 0.5346807         A LINESTRING (138.6252 -34.80...
#> 9     2 10 0.1204222         C LINESTRING (138.6252 -34.80...
#> 10    2 18 0.4268030         A LINESTRING (138.6252 -34.80...
```

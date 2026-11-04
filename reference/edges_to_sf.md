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
#> Simple feature collection with 123 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5865 ymin: -34.92444 xmax: 138.6257 ymax: -34.80578
#> CRS:           NA
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  2 0.1693656         C LINESTRING (138.6175 -34.80...
#> 2     1  5 0.4976975         C LINESTRING (138.6175 -34.80...
#> 3     1  6 0.9625171         C LINESTRING (138.6175 -34.80...
#> 4     1 11 0.3828377         C LINESTRING (138.6175 -34.80...
#> 5     1 15 0.7598141         A LINESTRING (138.6175 -34.80...
#> 6     1 26 0.6994359         A LINESTRING (138.6175 -34.80...
#> 7     1 29 0.3892637         A LINESTRING (138.6175 -34.80...
#> 8     1 31 0.3483325         B LINESTRING (138.6175 -34.80...
#> 9     1 39 0.4365325         A LINESTRING (138.6175 -34.80...
#> 10    2  7 0.4226868         A LINESTRING (138.6233 -34.81...
```

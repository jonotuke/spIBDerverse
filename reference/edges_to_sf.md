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
#> Simple feature collection with 118 features and 3 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5865 ymin: -34.92726 xmax: 138.6255 ymax: -34.80636
#> CRS:           NA
#> First 10 features:
#>    from to       wij                       geometry
#> 1     1  7 0.4167132 LINESTRING (138.6208 -34.81...
#> 2     1 24 0.1227858 LINESTRING (138.6208 -34.81...
#> 3     1 25 0.7071113 LINESTRING (138.6208 -34.81...
#> 4     1 30 0.5875003 LINESTRING (138.6208 -34.81...
#> 5     2  5 0.1766006 LINESTRING (138.5907 -34.91...
#> 6     2 16 0.1334612 LINESTRING (138.5907 -34.91...
#> 7     2 22 0.8175662 LINESTRING (138.5907 -34.91...
#> 8     2 32 0.8752791 LINESTRING (138.5907 -34.91...
#> 9     2 33 0.6294479 LINESTRING (138.5907 -34.91...
#> 10    3  9 0.5264046 LINESTRING (138.5929 -34.92...
```

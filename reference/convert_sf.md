# Convert to SF

Converts an igraph object into two sf objects

## Usage

``` r
convert_sf(g, lat, lon, col = "site")
```

## Arguments

- g:

  igraph network

- lat:

  attribute that gives latitude

- lon:

  attribute that gives longitude

- col:

  attribute that will give colour in leaflet or plot

## Value

list of edges_sf and nodes_sf

## Examples

``` r
convert_sf(example_network,"lat","long",col = "site")
#> $nodes_sf
#> Simple feature collection with 40 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.5867 ymin: -34.92707 xmax: 138.6253 ymax: -34.8057
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>    genetic_sex col name degree label                   geometry
#> 1            F   A    1      1  1: A POINT (138.6034 -34.91626)
#> 2            M   A    2      6  2: A POINT (138.6076 -34.91748)
#> 3            M   C    3     11  3: C POINT (138.6172 -34.80706)
#> 4            M   C    4      5  4: C POINT (138.6188 -34.81195)
#> 5            M   C    5      5  5: C POINT (138.6253 -34.81176)
#> 6            F   A    6      2  6: A POINT (138.6064 -34.91451)
#> 7            M   B    7      7  7: B POINT (138.5893 -34.91751)
#> 8            F   C    8      7  8: C POINT (138.6216 -34.80782)
#> 9            F   B    9      4  9: B POINT (138.5952 -34.92109)
#> 10           M   B   10      6 10: B POINT (138.5957 -34.92578)
#> 
#> $edges_sf
#> Simple feature collection with 111 features and 3 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.5867 ymin: -34.92707 xmax: 138.6253 ymax: -34.8057
#> Geodetic CRS:  WGS 84
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
#> 
```

# Adjust BB for network work sf object

Adjust BB for network work sf object

## Usage

``` r
add_convert_bb_adj(network_sf, asp = 1)
```

## Arguments

- network_sf:

  network sf objects

- asp:

  aspect ratio

## Value

same network sf with adjusted aspect ration

## Examples

``` r
add_convert_bb_adj(example_sf)
#> $nodes_sf
#> Simple feature collection with 40 features and 4 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.4653 ymin: -34.93921 xmax: 138.7467 ymax: -34.79356
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>    genetic_sex site name degree                   geometry
#> 1            F    A    1      1 POINT (138.6034 -34.91626)
#> 2            M    A    2      6 POINT (138.6076 -34.91748)
#> 3            M    C    3     11 POINT (138.6172 -34.80706)
#> 4            M    C    4      5 POINT (138.6188 -34.81195)
#> 5            M    C    5      5 POINT (138.6253 -34.81176)
#> 6            F    A    6      2 POINT (138.6064 -34.91451)
#> 7            M    B    7      7 POINT (138.5893 -34.91751)
#> 8            F    C    8      7 POINT (138.6216 -34.80782)
#> 9            F    B    9      4 POINT (138.5952 -34.92109)
#> 10           M    B   10      6 POINT (138.5957 -34.92578)
#> 
#> $edges_sf
#> Simple feature collection with 111 features and 3 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4653 ymin: -34.93921 xmax: 138.7467 ymax: -34.79356
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

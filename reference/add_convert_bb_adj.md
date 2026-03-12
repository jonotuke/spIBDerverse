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
#> w is 0.0389537171396341
#> h is 0.120905876470218
#> $nodes_sf
#> Simple feature collection with 40 features and 4 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.4656 ymin: -34.93936 xmax: 138.7464 ymax: -34.79427
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>    genetic_sex site name degree                   geometry
#> 1            F    C    1      4 POINT (138.6208 -34.81259)
#> 2            F    B    2      5 POINT (138.5907 -34.91765)
#> 3            M    B    3      5 POINT (138.5929 -34.92301)
#> 4            M    C    4     10 POINT (138.6212 -34.81093)
#> 5            F    C    5      6 POINT (138.6218 -34.80636)
#> 6            M    A    6      5 POINT (138.6063 -34.92223)
#> 7            M    C    7      8 POINT (138.6226 -34.81434)
#> 8            F    C    8      7 POINT (138.6232 -34.80676)
#> 9            M    A    9      7 POINT (138.6086 -34.91558)
#> 10           F    B   10      6 POINT (138.5892 -34.92378)
#> 
#> $edges_sf
#> Simple feature collection with 118 features and 3 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4656 ymin: -34.93936 xmax: 138.7464 ymax: -34.79427
#> Geodetic CRS:  WGS 84
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
#> 
```

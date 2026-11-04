# Convert to SF

Converts an igraph object into two sf objects

## Usage

``` r
convert_sf(g, lat, lon, jitter = 0, landscape = TRUE, crs = 3857)
```

## Arguments

- g:

  igraph network

- lat:

  attribute that gives latitude

- lon:

  attribute that gives longitude

- jitter:

  amount of jitter to add

- landscape:

  if true changes bounding box to be landscape

- crs:

  default CRS to use, using Web Mercator

## Value

list of edges_sf and nodes_sf

## Examples

``` r
convert_sf(example_network,"lat","long")
#> $nodes_sf
#> Simple feature collection with 40 features and 13 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.4643 ymin: -34.93962 xmax: 138.7481 ymax: -34.79257
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    genetic_sex site name .degree  .closeness .betweenness .eigencentrality
#> 1            F    C    1      12 0.013513514    64.532316        0.9859700
#> 2            M    C    2       5 0.011111111     6.227295        0.3249714
#> 3            M    B    3       8 0.012500000    39.078518        0.3601635
#> 4            F    C    4       7 0.010526316     9.868254        0.6334425
#> 5            F    C    5      10 0.012048193    15.427271        0.8925708
#> 6            F    B    6       6 0.012195122    54.643854        0.3008246
#> 7            F    B    7       3 0.009615385    10.360714        0.1470000
#> 8            M    A    8       4 0.009523810     5.813312        0.1302426
#> 9            F    C    9      11 0.012345679    48.205757        0.8823853
#> 10           M    A   10       4 0.010204082     8.037346        0.1420306
#>    .louvain .louvain_weighted .eigen .eigen_weighted .label_prop
#> 1        L1               Lw1     E1             Ew1         LP1
#> 2        L2               Lw2     E2             Ew2         LP2
#> 3        L2               Lw2     E2             Ew4         LP2
#> 4        L1               Lw1     E1             Ew1         LP1
#> 5        L1               Lw1     E1             Ew1         LP1
#> 6        L2               Lw2     E3             Ew4         LP1
#> 7        L3               Lw3     E3             Ew3         LP1
#> 8        L4               Lw2     E5             Ew2         LP2
#> 9        L1               Lw1     E1             Ew1         LP1
#> 10       L4               Lw4     E5             Ew2         LP2
#>    .label_prop_weighted                   geometry
#> 1                  LPw1  POINT (138.6196 -34.8081)
#> 2                  LPw2 POINT (138.6228 -34.80733)
#> 3                  LPw3 POINT (138.5934 -34.92737)
#> 4                  LPw1 POINT (138.6195 -34.81342)
#> 5                  LPw1 POINT (138.6255 -34.80847)
#> 6                  LPw1 POINT (138.5924 -34.91937)
#> 7                  LPw1 POINT (138.5944 -34.92397)
#> 8                  LPw3 POINT (138.6014 -34.91964)
#> 9                  LPw1  POINT (138.625 -34.80848)
#> 10                 LPw3 POINT (138.6028 -34.92054)
#> 
#> $edges_sf
#> Simple feature collection with 134 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4643 ymin: -34.93962 xmax: 138.7481 ymax: -34.79257
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.3212518         C LINESTRING (138.6196 -34.80...
#> 2     1  5 0.2897919         B LINESTRING (138.6196 -34.80...
#> 3     1  6 0.2363979         A LINESTRING (138.6196 -34.80...
#> 4     1  9 0.3855643         C LINESTRING (138.6196 -34.80...
#> 5     1 14 0.3415299         A LINESTRING (138.6196 -34.80...
#> 6     1 18 0.9767435         A LINESTRING (138.6196 -34.80...
#> 7     1 19 0.1005529         C LINESTRING (138.6196 -34.80...
#> 8     1 28 0.1348123         C LINESTRING (138.6196 -34.80...
#> 9     1 30 0.8850077         B LINESTRING (138.6196 -34.80...
#> 10    1 32 0.6536263         C LINESTRING (138.6196 -34.80...
#> 
```

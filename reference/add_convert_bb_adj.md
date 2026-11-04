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
#> Simple feature collection with 40 features and 13 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.4402 ymin: -35.00961 xmax: 138.7721 ymax: -34.7206
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    genetic_sex site name .degree  .closeness .betweenness .eigencentrality
#> 1            F    C    1       9 0.012195122    24.035512        0.7484435
#> 2            F    C    2       9 0.012658228    25.096138        0.8405598
#> 3            F    B    3       5 0.010989011    15.124866        0.2677023
#> 4            M    A    4       2 0.009345794     1.211111        0.1215062
#> 5            F    C    5      10 0.013157895    31.130300        0.8803313
#> 6            F    B    6       6 0.012048193    17.992134        0.3899440
#> 7            M    C    7      13 0.013698630    88.679146        0.9998877
#> 8            M    A    8       3 0.010204082     3.499889        0.2176486
#> 9            M    B    9       4 0.010204082     6.617410        0.1421484
#> 10           F    A   10       4 0.010638298    14.226476        0.1658163
#>    .louvain .louvain_weighted .eigen .eigen_weighted .label_prop
#> 1        L1               Lw1     E1             Ew1         LP1
#> 2        L1               Lw2     E3             Ew2         LP1
#> 3        L2               Lw1     E2             Ew3         LP1
#> 4        L3               Lw2     E3             Ew2         LP1
#> 5        L1               Lw1     E1             Ew3         LP1
#> 6        L2               Lw1     E4             Ew5         LP1
#> 7        L4               Lw3     E3             Ew2         LP1
#> 8        L5               Lw3     E2             Ew2         LP1
#> 9        L5               Lw3     E2             Ew5         LP1
#> 10       L3               Lw3     E4             Ew5         LP1
#>    .label_prop_weighted                   geometry
#> 1                  LPw1  POINT (138.6175 -34.8066)
#> 2                  LPw1 POINT (138.6233 -34.81226)
#> 3                  LPw1  POINT (138.588 -34.92225)
#> 4                  LPw1  POINT (138.601 -34.92303)
#> 5                  LPw1  POINT (138.6182 -34.8142)
#> 6                  LPw1 POINT (138.5952 -34.92296)
#> 7                  LPw1 POINT (138.6176 -34.80578)
#> 8                  LPw1 POINT (138.6028 -34.91406)
#> 9                  LPw1 POINT (138.5952 -34.92114)
#> 10                 LPw1 POINT (138.6071 -34.91425)
#> 
#> $edges_sf
#> Simple feature collection with 123 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4402 ymin: -35.00961 xmax: 138.7721 ymax: -34.7206
#> Projected CRS: WGS 84 / Pseudo-Mercator
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
#> 
```

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
#> Simple feature collection with 40 features and 7 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.4647 ymin: -34.93937 xmax: 138.7474 ymax: -34.79237
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    genetic_sex site name .degree  .closeness .betweenness .eigencentrality
#> 1            F    A    1       6 0.011764706     85.73485      0.181443706
#> 2            M    C    2      10 0.012658228     64.25350      0.865145326
#> 3            M    A    3       1 0.007407407      0.00000      0.060954402
#> 4            F    A    4       3 0.009615385     18.84524      0.059380591
#> 5            M    C    5       7 0.011494253     57.91789      0.517204940
#> 6            F    A    6       3 0.010526316     23.80952      0.248262548
#> 7            F    C    7       6 0.011494253     22.57662      0.454630983
#> 8            F    A    8       1 0.007042254      0.00000      0.009612535
#> 9            M    B    9       4 0.010101010     29.08889      0.204988617
#> 10           M    C   10      11 0.012658228     75.11760      0.887061308
#>                      geometry
#> 1  POINT (138.6066 -34.91959)
#> 2  POINT (138.6198 -34.81178)
#> 3  POINT (138.6095 -34.91456)
#> 4  POINT (138.6059 -34.91497)
#> 5  POINT (138.6227 -34.80951)
#> 6  POINT (138.6102 -34.92215)
#> 7   POINT (138.6193 -34.8055)
#> 8   POINT (138.605 -34.92051)
#> 9  POINT (138.5933 -34.92135)
#> 10 POINT (138.6228 -34.80603)
#> 
#> $edges_sf
#> Simple feature collection with 104 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4647 ymin: -34.93937 xmax: 138.7474 ymax: -34.79237
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.8870518         C LINESTRING (138.6066 -34.91...
#> 2     1 13 0.1208347         A LINESTRING (138.6066 -34.91...
#> 3     1 19 0.8034147         A LINESTRING (138.6066 -34.91...
#> 4     1 26 0.6814461         A LINESTRING (138.6066 -34.91...
#> 5     1 30 0.2271457         A LINESTRING (138.6066 -34.91...
#> 6     1 31 0.8612543         A LINESTRING (138.6066 -34.91...
#> 7     2  6 0.4279519         A LINESTRING (138.6198 -34.81...
#> 8     2 10 0.4448979         B LINESTRING (138.6198 -34.81...
#> 9     2 22 0.8704754         B LINESTRING (138.6198 -34.81...
#> 10    2 23 0.6761962         A LINESTRING (138.6198 -34.81...
#> 
```

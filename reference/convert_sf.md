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
#> Bounding box:  xmin: 138.4662 ymin: -34.93942 xmax: 138.7445 ymax: -34.79425
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    genetic_sex site name degree   closeness betweenness eigencentrality
#> 1            F    C    1      4 0.009433962   14.215476      0.18812328
#> 2            F    C    2      4 0.010309278   23.279004      0.27848501
#> 3            F    C    3      3 0.009009009   13.356349      0.14823893
#> 4            F    A    4      2 0.007751938    2.190079      0.05408051
#> 5            F    B    5      4 0.010204082   26.004365      0.23768274
#> 6            M    A    6      6 0.011494253   51.930098      0.50835983
#> 7            F    A    7      3 0.010204082   22.986447      0.19207611
#> 8            F    A    8      4 0.009433962   29.492460      0.11981775
#> 9            M    B    9      6 0.011235955   26.283825      0.60139785
#> 10           M    B   10      4 0.010752688   13.987807      0.43258544
#>                      geometry
#> 1  POINT (138.6163 -34.80808)
#> 2  POINT (138.6161 -34.80641)
#> 3  POINT (138.6219 -34.80756)
#> 4  POINT (138.6036 -34.92339)
#> 5  POINT (138.5908 -34.91942)
#> 6  POINT (138.6068 -34.92064)
#> 7  POINT (138.6054 -34.91428)
#> 8  POINT (138.6067 -34.91773)
#> 9  POINT (138.5951 -34.91846)
#> 10 POINT (138.5872 -34.92574)
#> 
#> $edges_sf
#> Simple feature collection with 99 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4662 ymin: -34.93942 xmax: 138.7445 ymax: -34.79425
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1 21 0.4073892         C LINESTRING (138.6163 -34.80...
#> 2     1 26 0.4753938         B LINESTRING (138.6163 -34.80...
#> 3     1 31 0.1535906         C LINESTRING (138.6163 -34.80...
#> 4     1 39 0.5229230         A LINESTRING (138.6163 -34.80...
#> 5     2  3 0.4245830         A LINESTRING (138.6161 -34.80...
#> 6     2 16 0.5748161         B LINESTRING (138.6161 -34.80...
#> 7     2 20 0.3075784         C LINESTRING (138.6161 -34.80...
#> 8     2 31 0.9981113         B LINESTRING (138.6161 -34.80...
#> 9     3  8 0.6680249         C LINESTRING (138.6219 -34.80...
#> 10    3 16 0.8685398         A LINESTRING (138.6219 -34.80...
#> 
```

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
#> Bounding box:  xmin: 138.4649 ymin: -34.93962 xmax: 138.7475 ymax: -34.79219
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    genetic_sex site name .degree .closeness .betweenness .eigencentrality
#> 1            F    A    1       5 0.01123596    18.213147        0.2247068
#> 2            F    B    2       7 0.01176471    29.129408        0.2557321
#> 3            M    A    3       3 0.01020408     3.273276        0.1829988
#> 4            F    A    4       6 0.01176471    27.880198        0.2584343
#> 5            M    A    5       7 0.01315789    34.602111        0.4149645
#> 6            M    B    6       9 0.01265823    39.930400        0.4566632
#> 7            M    A    7       3 0.01020408     2.730159        0.1856325
#> 8            M    B    8       9 0.01204819    28.548814        0.4966020
#> 9            F    B    9       8 0.01219512    53.155886        0.3595711
#> 10           F    B   10       5 0.01000000     6.909267        0.1528328
#>    .louvain .louvain_weighted .eigen .eigen_weighted .label_prop
#> 1         1                 1      1               1           1
#> 2         2                 2      2               2           2
#> 3         2                 3      5               2           2
#> 4         2                 2      2               2           2
#> 5         2                 3      2               2           2
#> 6         2                 3      2               2           2
#> 7         3                 1      4               1           1
#> 8         2                 3      2               2           2
#> 9         2                 2      2               2           2
#> 10        2                 2      2               2           2
#>    .label_prop_weighted                   geometry
#> 1                     1 POINT (138.6028 -34.91625)
#> 2                     2 POINT (138.5878 -34.92733)
#> 3                     2 POINT (138.6035 -34.92004)
#> 4                     2 POINT (138.6075 -34.92095)
#> 5                     2 POINT (138.6034 -34.91615)
#> 6                     2 POINT (138.5955 -34.91882)
#> 7                     2 POINT (138.6019 -34.91857)
#> 8                     2 POINT (138.5942 -34.92152)
#> 9                     2 POINT (138.5886 -34.91903)
#> 10                    2 POINT (138.5898 -34.92235)
#> 
#> $edges_sf
#> Simple feature collection with 133 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4649 ymin: -34.93962 xmax: 138.7475 ymax: -34.79219
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  4 0.4105681         B LINESTRING (138.6028 -34.91...
#> 2     1 25 0.1825956         A LINESTRING (138.6028 -34.91...
#> 3     1 29 0.4240473         A LINESTRING (138.6028 -34.91...
#> 4     1 33 0.9754908         B LINESTRING (138.6028 -34.91...
#> 5     1 38 0.9277891         A LINESTRING (138.6028 -34.91...
#> 6     2  4 0.6772017         A LINESTRING (138.5878 -34.92...
#> 7     2  9 0.7726272         A LINESTRING (138.5878 -34.92...
#> 8     2 10 0.4193386         B LINESTRING (138.5878 -34.92...
#> 9     2 12 0.5715213         A LINESTRING (138.5878 -34.92...
#> 10    2 15 0.7370064         B LINESTRING (138.5878 -34.92...
#> 
```

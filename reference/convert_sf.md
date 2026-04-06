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
#> Bounding box:  xmin: 138.4683 ymin: -34.93848 xmax: 138.7442 ymax: -34.79479
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    genetic_sex site name .degree  .closeness .betweenness .eigencentrality
#> 1            M    A    1       9 0.012195122     72.46180        0.6621726
#> 2            F    A    2       6 0.011904762     46.42886        0.3775914
#> 3            F    B    3       6 0.010526316     64.21005        0.2540814
#> 4            F    B    4       8 0.011235955     56.43515        0.3980026
#> 5            M    C    5       9 0.012345679     74.17724        0.7813991
#> 6            F    A    6       1 0.007518797      0.00000        0.0375577
#> 7            M    C    7       7 0.011494253     28.35714        0.7634568
#> 8            F    A    8       2 0.009090909      0.00000        0.1177893
#> 9            M    C    9      10 0.013157895     59.02709        1.0000000
#> 10           M    B   10       5 0.011627907     26.31650        0.4457774
#>                      geometry
#> 1  POINT (138.6035 -34.91641)
#> 2  POINT (138.6029 -34.91459)
#> 3  POINT (138.5934 -34.92403)
#> 4  POINT (138.5942 -34.91949)
#> 5  POINT (138.6216 -34.81381)
#> 6  POINT (138.6103 -34.91747)
#> 7  POINT (138.6159 -34.81377)
#> 8  POINT (138.6069 -34.92241)
#> 9  POINT (138.6161 -34.81082)
#> 10 POINT (138.5902 -34.92298)
#> 
#> $edges_sf
#> Simple feature collection with 110 features and 4 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 138.4683 ymin: -34.93848 xmax: 138.7442 ymax: -34.79479
#> Projected CRS: WGS 84 / Pseudo-Mercator
#> First 10 features:
#>    from to       wij edge_type                       geometry
#> 1     1  9 0.5285331         C LINESTRING (138.6035 -34.91...
#> 2     1 13 0.2139032         C LINESTRING (138.6035 -34.91...
#> 3     1 14 0.8284278         C LINESTRING (138.6035 -34.91...
#> 4     1 15 0.2564991         C LINESTRING (138.6035 -34.91...
#> 5     1 17 0.3335371         C LINESTRING (138.6035 -34.91...
#> 6     1 19 0.7717315         C LINESTRING (138.6035 -34.91...
#> 7     1 20 0.2631826         C LINESTRING (138.6035 -34.91...
#> 8     1 25 0.7058799         C LINESTRING (138.6035 -34.91...
#> 9     1 28 0.4773074         B LINESTRING (138.6035 -34.91...
#> 10    2  5 0.8452066         A LINESTRING (138.6029 -34.91...
#> 
```

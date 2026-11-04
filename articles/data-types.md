# Data-types for spIBDerverse functions

``` r

library(spIBDerverse)
library(igraph)
#> 
#> Attaching package: 'igraph'
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
```

In the `spIBDerverse` package, we have two structures that are used by
most of the functions, and hence by the
[`spibder_app()`](https://jonotuke.github.io/spIBDerverse/reference/spibder_app.md)
which gives the shiny GUI.

The most common object and the primary one for the shiny app is an
`igraph` object. This is the primary data structure used by the `igraph`
object. @lst-igraph loads an example network and shows it structure.

Notice that to ensure that we do not have clashes if a user has already
add centrality measures, we often also add them using the function
`add_centrality_measures()` which adds the common centrality measures to
the igraph object but with names like `.degree`, the use of a prefix of
`.` should hopefully stop any clashes.

``` r

data(example_network)
example_network
#> IGRAPH 361a63b UN-- 40 134 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 361a63b (vertex names):
#>  [1] 1--4  1--5  1--6  1--9  1--14 1--18 1--19 1--28 1--30 1--32 1--35 1--36
#> [13] 2--9  2--14 2--15 2--20 2--29 3--6  3--15 3--16 3--21 3--29 3--33 3--37
#> [25] 3--39 4--5  4--7  4--17 4--30 4--32 4--35 5--9  5--13 5--17 5--18 5--28
#> [37] 5--30 5--32 5--36 6--27 6--33 6--34 6--35 7--18 7--38 8--22 8--25 8--29
#> + ... omitted several edges
```

If you would like to visualise the network on a map, then a node
attibute for longitude and latitude is necessary.

For some of the plotting functions for networks on maps, we also use a
network sf object. @lst-sf illustrates this object. We see that is is
list that contains two objects both of `sf` types, a node object that
contains information about the node positions represented as points, and
an edge object that contains the information for the edges represented
as linestring objects.

``` r

data(example_sf)
example_sf
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
```

A network sf object can be obtained from an igraph object as illustrated
in @lst-create.

``` r

example_sf <- convert_sf(
  example_network,
  "lat",
  "long",
  landscape = TRUE
)
```

The package `spIBDerverse` has the following example networks built-in:

- `example_network`,
- `example_network_2`,
- `example_network_3`,
- `example_sf`, and
- `dist_network`.

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
#> IGRAPH 05e5699 UN-- 40 123 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 05e5699 (vertex names):
#>  [1] 1--2  1--5  1--6  1--11 1--15 1--26 1--29 1--31 1--39 2--7  2--10 2--11
#> [13] 2--14 2--19 2--26 2--34 2--39 3--5  3--12 3--31 3--33 3--38 4--28 4--34
#> [25] 5--7  5--11 5--14 5--15 5--30 5--34 5--37 5--39 6--14 6--20 6--27 6--31
#> [37] 6--33 7--8  7--11 7--14 7--19 7--20 7--22 7--25 7--29 7--33 7--34 7--36
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
#> Bounding box:  xmin: 138.4678 ymin: -34.9363 xmax: 138.7444 ymax: -34.79391
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
#> Bounding box:  xmin: 138.4678 ymin: -34.9363 xmax: 138.7444 ymax: -34.79391
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

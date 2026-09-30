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
#> IGRAPH 22f3232 UN-- 40 110 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n), lat
#> | (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 22f3232 (vertex names):
#>  [1]  1-- 9  1--13  1--14  1--15  1--17  1--19  1--20  1--25  1--28  2-- 5
#> [11]  2--14  2--24  2--26  2--28  2--36  3-- 4  3-- 6  3--16  3--24  3--34
#> [21]  3--39  4-- 8  4--10  4--14  4--27  4--30  4--36  4--37  5-- 7  5-- 9
#> [31]  5--11  5--15  5--20  5--25  5--31  5--33  7-- 9  7--12  7--13  7--23
#> [41]  7--25  7--38  8--14  9--10  9--11  9--16  9--23  9--25  9--26  9--38
#> [51] 10--34 10--38 10--40 11--12 11--29 11--33 11--40 12--29 12--32 12--33
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
#> Simple feature collection with 40 features and 7 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 138.4662 ymin: -34.93942 xmax: 138.7445 ymax: -34.79425
#> Geodetic CRS:  WGS 84
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
#> Geodetic CRS:  WGS 84
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

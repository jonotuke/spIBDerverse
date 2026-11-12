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
#> IGRAPH 491ef6f UN-- 40 115 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 491ef6f (vertex names):
#>  [1] 1--4  1--17 1--24 1--27 1--30 2--3  2--5  2--8  2--10 2--18 2--21 2--29
#> [13] 2--32 3--8  3--10 3--16 3--25 3--32 4--17 4--24 4--38 5--8  5--16 5--28
#> [25] 5--32 5--38 6--10 6--15 6--23 6--24 6--27 6--30 6--35 6--36 6--38 7--9 
#> [37] 7--10 7--23 7--34 8--10 8--13 8--14 8--16 8--18 8--24 8--25 8--32 9--14
#> + ... omitted several edges
```

If you would like to visualise the network on a map, then a node
attibute for longitude and latitude is necessary.

The package `spIBDerverse` has the following example networks built-in:

- `example_network`,
- `example_network_2`,
- `example_network_3`,
- `example_sf`, and
- `dist_network`.

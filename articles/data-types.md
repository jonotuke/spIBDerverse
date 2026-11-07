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

The package `spIBDerverse` has the following example networks built-in:

- `example_network`,
- `example_network_2`,
- `example_network_3`,
- `example_sf`, and
- `dist_network`.

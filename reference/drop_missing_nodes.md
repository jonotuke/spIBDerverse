# drop_missing_nodes

Removes every vertex that has a missing value (NA) in any of the given
vertex attributes, along with its edges. If any vertices are removed, a
warning of class `ergm_missing_nodes_warning` is signalled so it can be
caught (e.g. in shiny) and shown to the user.

## Usage

``` r
drop_missing_nodes(network, preds)
```

## Arguments

- network:

  igraph object

- preds:

  vector of igraph vertex attribute names

## Value

the igraph object with incomplete vertices removed. The removed vertices
(names, or indices if unnamed) are stored in
`attr(result, "removed_nodes")`.

## Examples

``` r
drop_missing_nodes(example_network, c("site", "genetic_sex"))
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

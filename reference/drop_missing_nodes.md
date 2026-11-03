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
#> IGRAPH 0987835 UN-- 40 104 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n), lat
#> | (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 0987835 (vertex names):
#>  [1] 1 --4  1 --13 1 --19 1 --26 1 --30 1 --31 2 --6  2 --10 2 --22 2 --23
#> [11] 2 --24 2 --28 2 --30 2 --33 2 --37 2 --39 3 --20 4 --18 4 --29 5 --9 
#> [21] 5 --10 5 --14 5 --29 5 --30 5 --37 5 --40 6 --18 6 --30 7 --13 7 --28
#> [31] 7 --30 7 --32 7 --34 7 --36 8 --18 9 --10 9 --17 9 --35 10--14 10--22
#> [41] 10--25 10--28 10--29 10--32 10--37 10--39 11--17 11--19 12--22 13--25
#> [51] 13--27 13--36 13--38 14--22 14--28 14--37 14--39 15--16 16--20 16--22
#> + ... omitted several edges
```

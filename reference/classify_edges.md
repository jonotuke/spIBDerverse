# classify edges

classify edges

## Usage

``` r
classify_edges(g, filters = list())
```

## Arguments

- g:

  igraph obj

- filters:

  edge filters

## Value

igraph with edge attribute .edgetype

## Examples

``` r
classify_edges(example_network, filters = list(edge_type = "A"))
#> IGRAPH dac9594 UN-- 40 102 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), .crawl (v/c), wij (e/n), edge_type (e/c),
#> | .edgetype (e/c)
#> + edges from dac9594 (vertex names):
#>  [1] 1--8  1--23 1--34 2--14 2--30 2--32 2--36 2--38 3--12 3--14 3--25 3--29
#> [13] 3--40 4--15 4--30 4--31 4--34 4--40 5--16 5--33 6--7  6--12 6--25 6--26
#> [25] 6--27 7--9  7--25 7--26 8--14 8--22 8--23 8--32 8--40 9--13 9--25 9--27
#> + ... omitted several edges
```

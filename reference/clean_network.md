# Clean network

Removes all nodes with NAs for a given attribute so can fit ERGM models

## Usage

``` r
clean_network(g, col)
```

## Arguments

- g:

  IBD igraph obj

- col:

  node attribute

## Value

cleaned IBD igraph obj

## Examples

``` r
clean_network(example_network_3, "site")
#> IGRAPH 53044d2 UN-- 37 119 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 53044d2 (vertex names):
#>  [1] 1--4  1--5  1--6  1--9  1--14 1--18 1--19 1--28 1--30 1--32 1--35 2--9 
#> [13] 2--14 2--15 2--20 2--29 3--6  3--15 3--16 3--21 3--29 3--33 3--37 3--39
#> [25] 4--5  4--7  4--17 4--30 4--32 4--35 5--9  5--17 5--18 5--28 5--30 5--32
#> [37] 6--27 6--33 6--34 6--35 7--18 7--38 8--22 8--25 8--29 8--39 9--17 9--21
#> + ... omitted several edges
```

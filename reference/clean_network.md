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
#> IGRAPH 97eb4b1 UN-- 37 113 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 97eb4b1 (vertex names):
#>  [1] 1--2  1--5  1--6  1--11 1--15 1--26 1--29 1--31 1--39 2--7  2--10 2--11
#> [13] 2--14 2--19 2--26 2--34 2--39 3--5  3--31 3--33 3--38 4--28 4--34 5--7 
#> [25] 5--11 5--14 5--15 5--30 5--34 5--37 5--39 6--14 6--20 6--27 6--31 6--33
#> [37] 7--8  7--11 7--14 7--19 7--20 7--22 7--25 7--29 7--33 7--34 8--21 8--30
#> + ... omitted several edges
```

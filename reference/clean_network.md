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
#> IGRAPH 0915a25 UN-- 37 113 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 0915a25 (vertex names):
#>  [1] 1--4  1--25 1--29 1--33 1--38 2--4  2--9  2--10 2--15 2--27 3--8  3--35
#> [13] 3--37 4--5  4--6  4--10 4--14 5--6  5--8  5--25 5--26 5--32 5--40 6--8 
#> [25] 6--9  6--16 6--30 6--37 6--40 7--19 7--22 7--38 8--9  8--15 8--16 8--18
#> [37] 8--37 8--40 9--10 9--19 9--21 9--39 9--40
#> + ... omitted several edges
```

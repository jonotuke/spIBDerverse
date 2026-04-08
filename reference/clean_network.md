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
#> IGRAPH 762d27c UN-- 37 96 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n), lat
#> | (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 762d27c (vertex names):
#>  [1]  1-- 9  1--14  1--15  1--17  1--19  1--20  1--25  1--28  2-- 5  2--14
#> [11]  2--24  2--26  2--28  3-- 4  3-- 6  3--16  3--24  3--34  3--39  4-- 8
#> [21]  4--10  4--14  4--27  4--30  4--37  5-- 7  5-- 9  5--11  5--15  5--20
#> [31]  5--25  5--31  5--33  7-- 9  7--23  7--25  7--38  8--14  9--10  9--11
#> [41]  9--16  9--23  9--25  9--26  9--38 10--34 10--38 10--40 11--29 11--33
#> [51] 11--40 14--16 14--24 14--27 15--18 15--21 15--25 16--24 16--30 16--33
#> + ... omitted several edges
```

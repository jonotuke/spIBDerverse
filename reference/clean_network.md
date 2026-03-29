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
#> IGRAPH 8d2b598 UN-- 37 86 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n),
#> | closeness (v/n), betweenness (v/n), eigencentrality (v/n), lat (v/n),
#> | long (v/n), wij (e/n)
#> + edges from 8d2b598 (vertex names):
#>  [1]  1-- 6  1--21  1--24  1--29  1--31  1--40  2-- 6  2--16  3--11  3--28
#> [11]  3--35  4-- 6  4--24  5-- 9  5--30  6--11  6--18  6--30  6--33  7--17
#> [21]  7--18  7--22  7--23  7--24  8--15  8--19  8--25  8--26  8--30  8--37
#> [31]  8--40  9--32  9--34 10--20 10--21 10--31 10--33 11--27 11--28 14--25
#> [41] 14--31 15--19 15--25 15--29 15--37 15--38 16--18 16--21 16--26 16--28
#> [51] 16--32 17--18 17--29 18--22 18--23 18--25 18--29 19--25 19--38 19--40
#> + ... omitted several edges
```

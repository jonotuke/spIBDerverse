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
#> IGRAPH 6d48cde UN-- 37 96 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n), lat
#> | (v/n), long (v/n), wij (e/n)
#> + edges from 6d48cde (vertex names):
#>  [1]  1--27  2-- 5  2-- 7  2--11  2--23  2--34  3-- 4  3-- 5  3-- 7  3--10
#> [11]  3--16  3--19  3--21  3--30  3--33  3--35  4-- 8  4--10  4--30  4--33
#> [21]  5--28  5--33  5--35  6--27  6--30  7--10  7--22  7--29  7--32  7--38
#> [31]  8--20  8--26  8--27  8--31  8--33  8--35  9--15  9--22  9--27 10--22
#> [41] 10--24 10--29 11--19 11--31 14--18 14--35 14--37 15--26 15--27 15--37
#> [51] 16--31 16--34 17--18 17--21 17--28 17--30 17--35 17--39 17--40 18--25
#> [61] 19--34 20--27 20--39 21--28 21--30 21--31 21--33 21--35 21--37 21--39
#> + ... omitted several edges
```

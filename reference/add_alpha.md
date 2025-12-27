# Add alpha

Add alpha

## Usage

``` r
add_alpha(g, measure = NULL)
```

## Arguments

- g:

  igraph network

- measure:

  centrality measure to set .alpha to

## Value

igraph network with an vertex attribute called .alpha set to give
centrality measure that can be used in
[plot_ggnet](https://jonotuke.github.io/spIBDerverse/reference/plot_ggnet.md)

## Examples

``` r
add_alpha(example_network, "degree")
#> IGRAPH b145b76 UN-- 40 111 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n), lat
#> | (v/n), long (v/n), .id (v/n), .alpha (v/n), wij (e/n)
#> + edges from b145b76 (vertex names):
#>  [1]  1--27  2-- 5  2-- 7  2--11  2--12  2--23  2--34  3-- 4  3-- 5  3-- 7
#> [11]  3--10  3--13  3--16  3--19  3--21  3--30  3--33  3--35  4-- 8  4--10
#> [21]  4--30  4--33  5--28  5--33  5--35  6--27  6--30  7--10  7--22  7--29
#> [31]  7--32  7--38  8--20  8--26  8--27  8--31  8--33  8--35  9--12  9--15
#> [41]  9--22  9--27 10--22 10--24 10--29 11--19 11--31 12--19 12--22 12--23
#> [51] 13--17 13--28 13--30 13--35 13--39 13--40 14--18 14--35 14--37 15--26
#> [61] 15--27 15--36 15--37 16--31 16--34 17--18 17--21 17--28 17--30 17--35
#> + ... omitted several edges
```

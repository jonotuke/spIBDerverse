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
#> IGRAPH 1619fd7 UN-- 40 118 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n), lat
#> | (v/n), long (v/n), .id (v/n), .alpha (v/n), wij (e/n)
#> + edges from 1619fd7 (vertex names):
#>  [1]  1-- 7  1--24  1--25  1--30  2-- 5  2--16  2--22  2--32  2--33  3-- 9
#> [11]  3--36  3--37  3--38  3--39  4-- 5  4-- 6  4-- 7  4-- 8  4-- 9  4--13
#> [21]  4--16  4--21  4--24  4--25  5-- 7  5-- 8  5--24  5--25  6--11  6--21
#> [31]  6--31  6--36  7--13  7--16  7--21  7--28  7--36  8--16  8--21  8--24
#> [41]  8--25  8--30  9--12  9--18  9--19  9--23  9--25 10--19 10--22 10--30
#> [51] 10--32 10--33 10--40 11--13 11--16 11--21 11--24 11--25 11--27 12--26
#> [61] 12--35 13--19 13--20 13--25 13--30 13--31 13--34 14--19 14--20 14--21
#> + ... omitted several edges
```

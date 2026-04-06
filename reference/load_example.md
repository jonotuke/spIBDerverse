# loads some example data

For use in the data wizard module

## Usage

``` r
load_example(example = "example_network")
```

## Arguments

- example:

  name of example data to upload

## Value

example network

## Examples

``` r
load_example()
#> IGRAPH 22f3232 UN-- 40 110 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n), lat
#> | (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 22f3232 (vertex names):
#>  [1]  1-- 9  1--13  1--14  1--15  1--17  1--19  1--20  1--25  1--28  2-- 5
#> [11]  2--14  2--24  2--26  2--28  2--36  3-- 4  3-- 6  3--16  3--24  3--34
#> [21]  3--39  4-- 8  4--10  4--14  4--27  4--30  4--36  4--37  5-- 7  5-- 9
#> [31]  5--11  5--15  5--20  5--25  5--31  5--33  7-- 9  7--12  7--13  7--23
#> [41]  7--25  7--38  8--14  9--10  9--11  9--16  9--23  9--25  9--26  9--38
#> [51] 10--34 10--38 10--40 11--12 11--29 11--33 11--40 12--29 12--32 12--33
#> + ... omitted several edges
```

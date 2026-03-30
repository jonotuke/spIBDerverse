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
#> IGRAPH 6981829 UN-- 40 99 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n),
#> | closeness (v/n), betweenness (v/n), eigencentrality (v/n), lat (v/n),
#> | long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 6981829 (vertex names):
#>  [1]  1--21  1--26  1--31  1--39  2-- 3  2--16  2--20  2--31  3-- 8  3--16
#> [11]  4--12  4--22  5-- 8  5--15  5--38  5--39  6--10  6--12  6--20  6--24
#> [21]  6--28  6--36  7--12  7--31  7--38  8--12  8--22  9--14  9--15  9--19
#> [31]  9--36  9--38  9--40 10--11 10--15 10--23 11--14 11--23 11--27 11--34
#> [41] 11--35 11--36 11--37 13--27 13--29 13--40 14--16 14--20 14--23 14--30
#> [51] 14--34 14--37 14--38 15--38 15--39 16--30 16--32 16--34 17--20 17--24
#> + ... omitted several edges
```

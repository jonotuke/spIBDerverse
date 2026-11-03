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
#> IGRAPH f978838 UN-- 40 133 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from f978838 (vertex names):
#>  [1] 1--4  1--25 1--29 1--33 1--38 2--4  2--9  2--10 2--12 2--15 2--27 2--36
#> [13] 3--8  3--35 3--37 4--5  4--6  4--10 4--14 5--6  5--8  5--25 5--26 5--32
#> [25] 5--40 6--8  6--9  6--12 6--16 6--30 6--37 6--40 7--19 7--22 7--38 8--9 
#> [37] 8--15 8--16 8--18 8--37 8--40 9--10 9--19 9--21 9--39 9--40
#> + ... omitted several edges
```

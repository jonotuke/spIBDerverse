# converts NA to unknown

converts NA to unknown

converts NA to unknown

## Usage

``` r
convert_na_unknown(g, name)

convert_na_unknown(g, name)
```

## Arguments

- g:

  igraph object

- name:

  node attribute to convert

## Value

updated igraph object

updated igraph object

## Examples

``` r
convert_na_unknown(example_network_3, "site")
#> IGRAPH 361a63b UN-- 40 134 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 361a63b (vertex names):
#>  [1] 1--4  1--5  1--6  1--9  1--14 1--18 1--19 1--28 1--30 1--32 1--35 1--36
#> [13] 2--9  2--14 2--15 2--20 2--29 3--6  3--15 3--16 3--21 3--29 3--33 3--37
#> [25] 3--39 4--5  4--7  4--17 4--30 4--32 4--35 5--9  5--13 5--17 5--18 5--28
#> [37] 5--30 5--32 5--36 6--27 6--33 6--34 6--35 7--18 7--38 8--22 8--25 8--29
#> + ... omitted several edges
convert_na_unknown(example_network_3, "site")
#> IGRAPH 361a63b UN-- 40 134 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 361a63b (vertex names):
#>  [1] 1--4  1--5  1--6  1--9  1--14 1--18 1--19 1--28 1--30 1--32 1--35 1--36
#> [13] 2--9  2--14 2--15 2--20 2--29 3--6  3--15 3--16 3--21 3--29 3--33 3--37
#> [25] 3--39 4--5  4--7  4--17 4--30 4--32 4--35 5--9  5--13 5--17 5--18 5--28
#> [37] 5--30 5--32 5--36 6--27 6--33 6--34 6--35 7--18 7--38 8--22 8--25 8--29
#> + ... omitted several edges
```

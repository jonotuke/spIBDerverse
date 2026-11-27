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
#> IGRAPH 5557710 UN-- 37 85 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), .crawl (v/c), wij (e/n), edge_type (e/c)
#> + edges from 5557710 (vertex names):
#>  [1] 1 --8  1 --23 1 --34 2 --14 2 --30 2 --32 2 --38 3 --14 3 --25 3 --29
#> [11] 3 --40 4 --15 4 --30 4 --31 4 --34 4 --40 5 --16 5 --33 6 --7  6 --25
#> [21] 6 --26 6 --27 7 --9  7 --25 7 --26 8 --14 8 --22 8 --23 8 --32 8 --40
#> [31] 9 --25 9 --27 10--16 10--18 10--27 10--31 10--38 11--15 11--20 14--20
#> + ... omitted several edges
```

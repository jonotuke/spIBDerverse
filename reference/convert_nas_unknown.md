# converts all NAs in node attributes

converts all NAs in node attributes

## Usage

``` r
convert_nas_unknown(g)
```

## Arguments

- g:

  igraph object

## Value

igraph object with all NAs converted

## Examples

``` r
convert_nas_unknown(example_network_3)
#> IGRAPH 6e103bc UN-- 40 102 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 6e103bc (vertex names):
#>  [1] 1 --8  1 --23 1 --34 2 --14 2 --30 2 --32 2 --36 2 --38 3 --12 3 --14
#> [11] 3 --25 3 --29 3 --40 4 --15 4 --30 4 --31 4 --34 4 --40 5 --16 5 --33
#> [21] 6 --7  6 --12 6 --25 6 --26 6 --27 7 --9  7 --25 7 --26 8 --14 8 --22
#> [31] 8 --23 8 --32 8 --40 9 --13 9 --25 9 --27 10--16 10--18 10--27 10--31
#> + ... omitted several edges
```

# remove bad edges

remove bad edges

## Usage

``` r
remove_bad_edges(g)
```

## Arguments

- g:

  igraph object with edge variable .edgetype

## Value

igraph object

## Examples

``` r
classify_edges(example_network, filters = list(edge_type = "A")) |>
remove_bad_edges()
#> IGRAPH 84388fa UN-- 21 11 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), .crawl (v/c), wij (e/n), edge_type (e/c),
#> | .edgetype (e/c)
#> + edges from 84388fa (vertex names):
#>  [1] 1 --23 1 --34 2 --32 7 --9  10--31 11--15 11--20 12--19 22--29 24--34
#> [11] 31--34
```

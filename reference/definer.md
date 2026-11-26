# definer

definer

## Usage

``` r
definer(g, edge_filters = list())
```

## Arguments

- g:

  igraph object

- edge_filters:

  a list of edge attributes and cutoffs

## Value

igraph object

## Examples

``` r
definer(
example_network,
edge_filters = list(
wij = c(0.5, NA), edge_type = "A"
)
)
#> IGRAPH 13b7518 UN-- 40 19 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), .crawl (v/c), wij (e/n), edge_type (e/c)
#> + edges from 13b7518 (vertex names):
#>  [1] 1 --8  1 --34 5 --16 6 --12 6 --25 9 --27 10--27 12--19 14--20 14--37
#> [11] 14--39 16--32 17--22 20--39 24--28 24--34 28--30 31--34 33--38
```

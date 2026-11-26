# pruner

pruner

## Usage

``` r
pruner(g, edge_filters = list(), node_filters = list())
```

## Arguments

- g:

  igraph object

- edge_filters:

  edges to keep. The edges that are removed will remove vertices

- node_filters:

  nodes to keep

## Value

igraph object

## Examples

``` r
pruner(example_network,
edge_filters = list(edge_type = c("A", "B")),
node_filters = list(site = "A")
)
#> IGRAPH 9d0e0a4 UN-- 12 11 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), .crawl (v/c), .nodetype (v/c), wij (e/n),
#> | edge_type (e/c), .edgetype (e/c)
#> + edges from 9d0e0a4 (vertex names):
#>  [1] 1 --8  1 --34 2 --32 2 --38 8 --22 8 --32 22--29 24--34 33--37 33--38
#> [11] 35--37
```

# Convert to network from igraph, but keep original names

Convert to network from igraph, but keep original names

## Usage

``` r
convert_to_network(g)
```

## Arguments

- g:

  igraph object

## Value

network object

## Examples

``` r
convert_to_network(example_network_6)
#>  Network attributes:
#>   vertices = 40 
#>   directed = FALSE 
#>   hyper = FALSE 
#>   loops = FALSE 
#>   multiple = FALSE 
#>   bipartite = FALSE 
#>   total edges= 115 
#>     missing edges= 0 
#>     non-missing edges= 115 
#> 
#>  Vertex attribute names: 
#>     .betweenness .closeness .degree .eigen .eigen_weighted .eigencentrality .label_prop .label_prop_weighted .louvain .louvain_weighted Genetic Sex genetic_sex lat long site vertex.names 
#> 
#>  Edge attribute names: 
#>     edge_type wij 
```

# get_connected_graph

get_connected_graph

## Usage

``` r
get_connected_graph(g)
```

## Arguments

- g:

  igraph object

## Value

igraph object

## Examples

``` r
g <- igraph::sample_gnp(10, 0.5)
get_connected_graph(g)
#> IGRAPH bf238f3 U--- 10 15 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from bf238f3:
#>  [1] 2-- 3 2-- 4 1-- 5 4-- 5 3-- 6 2-- 7 3-- 7 4-- 7 5-- 8 3-- 9 4-- 9 7-- 9
#> [13] 1--10 3--10 9--10
```

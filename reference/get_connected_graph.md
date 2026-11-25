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
#> IGRAPH 6a6c2ce U--- 10 30 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 6a6c2ce:
#>  [1] 1-- 2 1-- 3 2-- 3 1-- 4 3-- 4 1-- 5 3-- 5 1-- 6 3-- 6 5-- 6 1-- 7 2-- 7
#> [13] 5-- 7 1-- 8 3-- 8 4-- 8 5-- 8 7-- 8 2-- 9 3-- 9 4-- 9 7-- 9 1--10 2--10
#> [25] 3--10 5--10 6--10 7--10 8--10 9--10
```

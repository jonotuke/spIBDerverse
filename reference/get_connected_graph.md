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
#> IGRAPH a90c60b U--- 10 26 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from a90c60b:
#>  [1] 1-- 2 2-- 3 1-- 4 2-- 4 3-- 4 2-- 5 3-- 5 1-- 6 2-- 6 1-- 7 3-- 7 4-- 7
#> [13] 6-- 7 3-- 8 4-- 8 6-- 8 1-- 9 2-- 9 4-- 9 6-- 9 7-- 9 8-- 9 1--10 3--10
#> [25] 5--10 7--10
```

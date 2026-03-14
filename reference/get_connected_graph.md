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
#> IGRAPH 0a5878b U--- 10 16 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 0a5878b:
#>  [1] 1-- 2 1-- 3 2-- 5 3-- 5 2-- 6 3-- 6 4-- 6 1-- 7 3-- 8 4-- 8 6-- 8 7-- 8
#> [13] 4-- 9 5-- 9 6-- 9 5--10
```

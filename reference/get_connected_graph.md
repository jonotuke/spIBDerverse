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
#> IGRAPH 3c1f0e2 U--- 10 20 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 3c1f0e2:
#>  [1] 3-- 4 1-- 5 2-- 5 3-- 5 4-- 5 4-- 6 3-- 7 5-- 7 6-- 7 1-- 8 3-- 8 4-- 8
#> [13] 1-- 9 5-- 9 7-- 9 8-- 9 1--10 5--10 6--10 7--10
```

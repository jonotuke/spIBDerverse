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
#> IGRAPH 4f61b13 U--- 10 21 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 4f61b13:
#>  [1] 1-- 2 1-- 3 3-- 4 2-- 5 3-- 6 2-- 7 3-- 7 4-- 7 1-- 8 2-- 8 3-- 8 6-- 8
#> [13] 7-- 8 1-- 9 2-- 9 3-- 9 4-- 9 6-- 9 1--10 2--10 3--10
```

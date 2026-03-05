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
#> IGRAPH 5c7f53f U--- 10 19 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 5c7f53f:
#>  [1] 1-- 2 2-- 3 1-- 4 2-- 5 3-- 5 4-- 5 2-- 7 4-- 8 5-- 8 6-- 8 7-- 8 1-- 9
#> [13] 2-- 9 5-- 9 1--10 2--10 4--10 5--10 7--10
```

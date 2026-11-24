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
#> IGRAPH 9138e78 U--- 10 20 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 9138e78:
#>  [1] 1-- 3 2-- 4 2-- 5 4-- 5 2-- 6 4-- 6 5-- 6 1-- 7 3-- 7 4-- 7 2-- 8 6-- 8
#> [13] 1-- 9 2-- 9 3-- 9 7-- 9 8-- 9 1--10 8--10 9--10
```

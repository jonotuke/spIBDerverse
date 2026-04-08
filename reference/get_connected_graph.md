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
#> IGRAPH 453e2b3 U--- 10 25 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 453e2b3:
#>  [1] 1-- 3 2-- 3 1-- 4 2-- 4 3-- 4 3-- 5 1-- 6 3-- 6 3-- 7 4-- 7 6-- 7 1-- 8
#> [13] 2-- 8 3-- 8 5-- 8 6-- 8 1-- 9 2-- 9 6-- 9 8-- 9 1--10 3--10 6--10 7--10
#> [25] 9--10
```

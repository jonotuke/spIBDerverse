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
#> IGRAPH d34fd8c U--- 10 17 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from d34fd8c:
#>  [1] 2-- 5 2-- 6 4-- 6 1-- 7 3-- 7 4-- 7 5-- 7 2-- 8 3-- 8 6-- 8 2-- 9 3-- 9
#> [13] 5-- 9 8-- 9 5--10 6--10 8--10
```

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
#> IGRAPH b6aa29c U--- 10 24 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from b6aa29c:
#>  [1] 1-- 2 1-- 3 1-- 5 3-- 5 4-- 5 1-- 6 2-- 6 4-- 6 5-- 6 3-- 7 4-- 7 6-- 7
#> [13] 1-- 8 4-- 8 5-- 8 1-- 9 3-- 9 5-- 9 2--10 3--10 5--10 6--10 7--10 8--10
```

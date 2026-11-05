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
#> IGRAPH 9d5c4eb U--- 10 25 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 9d5c4eb:
#>  [1] 2-- 3 1-- 4 2-- 4 1-- 5 2-- 5 3-- 5 4-- 5 1-- 6 3-- 6 4-- 6 1-- 7 2-- 7
#> [13] 3-- 7 4-- 7 1-- 8 2-- 8 4-- 8 5-- 8 6-- 8 7-- 8 1-- 9 3-- 9 4-- 9 5-- 9
#> [25] 6--10
```

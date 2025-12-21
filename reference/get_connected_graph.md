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
#> IGRAPH 1c8429c U--- 10 25 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 1c8429c:
#>  [1] 1-- 2 1-- 3 2-- 3 2-- 4 3-- 4 3-- 5 4-- 5 2-- 6 3-- 6 1-- 7 2-- 7 5-- 7
#> [13] 1-- 8 3-- 8 1-- 9 2-- 9 4-- 9 5-- 9 6-- 9 7-- 9 1--10 2--10 4--10 5--10
#> [25] 9--10
```

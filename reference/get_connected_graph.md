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
#> IGRAPH e7f2d11 U--- 10 27 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from e7f2d11:
#>  [1] 1-- 2 1-- 3 2-- 3 3-- 4 1-- 5 3-- 5 4-- 5 2-- 6 3-- 6 5-- 6 1-- 7 5-- 7
#> [13] 3-- 8 4-- 8 6-- 8 1-- 9 3-- 9 4-- 9 7-- 9 8-- 9 1--10 2--10 4--10 5--10
#> [25] 6--10 7--10 9--10
```

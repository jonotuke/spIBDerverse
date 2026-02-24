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
#> IGRAPH 82f4923 U--- 10 19 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 82f4923:
#>  [1] 2-- 3 1-- 4 3-- 4 1-- 5 1-- 6 2-- 6 3-- 6 5-- 7 7-- 8 1-- 9 2-- 9 3-- 9
#> [13] 4-- 9 5-- 9 8-- 9 4--10 5--10 7--10 8--10
```

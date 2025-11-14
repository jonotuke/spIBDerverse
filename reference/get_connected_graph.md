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
#> IGRAPH b51cf1c U--- 10 25 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from b51cf1c:
#>  [1] 1-- 2 1-- 3 2-- 3 2-- 5 4-- 5 1-- 6 2-- 6 3-- 6 5-- 6 1-- 7 4-- 7 5-- 7
#> [13] 1-- 8 2-- 8 5-- 8 6-- 8 2-- 9 4-- 9 6-- 9 3--10 4--10 6--10 7--10 8--10
#> [25] 9--10
```

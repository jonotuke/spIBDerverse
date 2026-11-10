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
#> IGRAPH de97704 U--- 10 13 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from de97704:
#>  [1] 2-- 3 3-- 4 4-- 5 1-- 6 2-- 6 4-- 7 3-- 8 4-- 8 7-- 8 2-- 9 4-- 9 2--10
#> [13] 7--10
```

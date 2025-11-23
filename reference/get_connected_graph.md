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
#> IGRAPH fcf1887 U--- 10 23 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from fcf1887:
#>  [1] 2-- 3 1-- 4 2-- 4 4-- 5 2-- 6 3-- 6 4-- 6 5-- 6 2-- 7 3-- 7 6-- 7 1-- 8
#> [13] 3-- 8 4-- 8 7-- 8 1-- 9 4-- 9 6-- 9 8-- 9 5--10 6--10 8--10 9--10
```

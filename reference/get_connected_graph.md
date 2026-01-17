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
#> IGRAPH 3ebc653 U--- 10 16 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 3ebc653:
#>  [1] 2-- 5 3-- 5 1-- 6 2-- 6 1-- 7 2-- 7 3-- 7 4-- 8 5-- 9 6-- 9 7-- 9 8-- 9
#> [13] 1--10 2--10 5--10 9--10
```

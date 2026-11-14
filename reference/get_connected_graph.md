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
#> IGRAPH 0b1c093 U--- 10 15 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 0b1c093:
#>  [1] 1-- 5 2-- 6 3-- 6 1-- 7 3-- 7 5-- 7 5-- 8 3-- 9 7-- 9 1--10 4--10 6--10
#> [13] 7--10 8--10 9--10
```

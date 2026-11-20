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
#> IGRAPH 0229bc2 U--- 8 15 -- Erdos-Renyi (gnp) graph
#> + attr: name (g/c), type (g/c), loops (g/l), p (g/n)
#> + edges from 0229bc2:
#>  [1] 1--2 1--4 1--5 2--5 3--5 4--5 3--6 4--6 5--6 2--7 3--7 5--7 6--7 1--8 4--8
```

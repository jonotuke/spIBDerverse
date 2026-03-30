# Filter network

Includes or excludes nodes based on regular expression

## Usage

``` r
filter_network(g, node_inc = "", node_exc = "")
```

## Arguments

- g:

  ibd network

- node_inc:

  regular expression for inclusion

- node_exc:

  regular expression for exclusion

## Value

filtered IBD network

## Examples

``` r
filter_network(example_network, node_exc = "1")
#> IGRAPH 72f8bc1 UN-- 27 43 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n),
#> | closeness (v/n), betweenness (v/n), eigencentrality (v/n), lat (v/n),
#> | long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 72f8bc1 (vertex names):
#>  [1]  2-- 3  2--20  3-- 8  4--22  5-- 8  5--38  5--39  6--20  6--24  6--28
#> [11]  6--36  7--38  8--22  9--36  9--38  9--40 20--26 20--27 20--34 22--27
#> [21] 23--24 23--40 24--26 24--27 24--29 24--35 24--38 25--27 25--34 25--35
#> [31] 27--29 27--35 27--37 28--33 28--34 28--40 30--34 32--39 33--36 33--38
#> [41] 35--36 35--40 38--40
```

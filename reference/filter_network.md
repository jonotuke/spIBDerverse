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
#> IGRAPH d9fbe85 UN-- 27 57 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n), lat
#> | (v/n), long (v/n), wij (e/n)
#> + edges from d9fbe85 (vertex names):
#>  [1]  2-- 5  2-- 7  2--23  2--34  3-- 4  3-- 5  3-- 7  3--30  3--33  3--35
#> [11]  4-- 8  4--30  4--33  5--28  5--33  5--35  6--27  6--30  7--22  7--29
#> [21]  7--32  7--38  8--20  8--26  8--27  8--33  8--35  9--22  9--27 20--27
#> [31] 20--39 22--25 22--29 22--33 22--38 23--27 24--38 25--28 25--32 26--39
#> [41] 27--28 27--39 28--30 28--33 28--35 28--37 28--39 28--40 29--34 30--35
#> [51] 30--37 33--38 35--37 35--39 36--39 37--39 39--40
```

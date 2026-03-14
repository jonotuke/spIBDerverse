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
#> IGRAPH db3b885 UN-- 27 49 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), degree (v/n), lat
#> | (v/n), long (v/n), wij (e/n)
#> + edges from db3b885 (vertex names):
#>  [1]  2-- 5  2--22  2--32  2--33  3-- 9  3--36  3--37  3--38  3--39  4-- 5
#> [11]  4-- 6  4-- 7  4-- 8  4-- 9  4--24  4--25  5-- 7  5-- 8  5--24  5--25
#> [21]  6--36  7--28  7--36  8--24  8--25  8--30  9--23  9--25 22--32 23--26
#> [31] 23--27 23--36 24--25 24--30 25--30 26--29 26--38 27--29 27--33 28--29
#> [41] 28--34 29--39 32--33 33--38 33--39 34--37 34--39 36--38 38--40
```

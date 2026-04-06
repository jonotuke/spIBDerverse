# Filter network

Includes or excludes nodes based on regular expression

## Usage

``` r
filter_network(
  g,
  node_inc = "",
  node_exc = "",
  filter_column = "none",
  cutoff = NULL,
  is_less_than = TRUE
)
```

## Arguments

- g:

  ibd network

- node_inc:

  regular expression for inclusion

- node_exc:

  regular expression for exclusion

- filter_column:

  node attribute to filter network on

- cutoff:

  cutoffs for filter

- is_less_than:

  in numeric filter do you keep less than or greater than

## Value

filtered IBD network

## Examples

``` r
filter_network(example_network, node_exc = "1")
#> IGRAPH 0e6d9c0 UN-- 27 53 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n), lat
#> | (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 0e6d9c0 (vertex names):
#>  [1]  2-- 5  2--24  2--26  2--28  2--36  3-- 4  3-- 6  3--24  3--34  3--39
#> [11]  4-- 8  4--27  4--30  4--36  4--37  5-- 7  5-- 9  5--20  5--25  5--33
#> [21]  7-- 9  7--23  7--25  7--38  9--23  9--25  9--26  9--38 22--28 22--35
#> [31] 23--25 23--26 23--37 23--38 23--40 24--29 24--30 24--35 25--38 26--37
#> [41] 26--40 27--38 28--33 28--38 29--30 29--39 30--37 30--40 32--34 33--37
#> [51] 33--40 37--40 39--40
```

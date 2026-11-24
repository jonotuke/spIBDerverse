# Filter network

Filter network

## Usage

``` r
filter_network(g, node_filters = list(), edge_filters = list())
```

## Arguments

- g:

  ibd network

- node_filters:

  named list of cutoffs to filter nodes on, one per node attribute, e.g.
  `list(site = c("A", "C"), genetic_sex = "F")`. A node must satisfy
  every filter to be kept.

- edge_filters:

  named list of cutoffs to filter edges on, one per edge attribute, e.g.
  `list(ibd = c(0.25, NA), type = "related")`. An edge must satisfy
  every filter to be kept.

## Value

filtered IBD network

## Details

Numeric attributes are filtered on a `c(min, max)` range (inclusive,
`NA` bounds are unbounded); all other attributes are filtered on the set
of values to keep. Missing values never pass a filter.

## Examples

``` r
filter_network(example_network, node_filters = list(site = "A"))
#> IGRAPH b5a685e UN-- 11 5 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from b5a685e (vertex names):
#> [1] 13--19 20--22 19--31 22--35 22--39
```

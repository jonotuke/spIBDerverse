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

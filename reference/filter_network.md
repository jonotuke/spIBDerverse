# Filter network

Filter network

## Usage

``` r
filter_network(
  g,
  node_filters = list(),
  edge_column = "none",
  edge_cutoff = NULL
)
```

## Arguments

- g:

  ibd network

- node_filters:

  list of values to filter on for nodes e.g. list(site = c("A", "C"),
  genetic_sex = "F")

- edge_column:

  edge attribute to filter network on

- edge_cutoff:

  cutoffs for edge filter

## Value

filtered IBD network

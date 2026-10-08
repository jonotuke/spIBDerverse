# Filter network

Includes or excludes nodes based on regular expression

## Usage

``` r
filter_network(
  g,
  node_column = "none",
  node_cutoff = NULL,
  edge_column = "none",
  edge_cutoff = NULL
)
```

## Arguments

- g:

  ibd network

- node_column:

  node attribute to filter network on

- node_cutoff:

  cutoffs for node filter

- edge_column:

  edge attributes to filter network on

- edge_cutoff:

  cutoffs for edge filter

## Value

filtered IBD network

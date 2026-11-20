# Find the vertex id from a name

Find the vertex id from a name

## Usage

``` r
names_to_ids(g, node_names)
```

## Arguments

- g:

  igraph object

- node_names:

  vector of node names

## Value

vector of node ids

## Examples

``` r
names_to_ids(example_network_2, "RKF040")
#> [1] 319
```

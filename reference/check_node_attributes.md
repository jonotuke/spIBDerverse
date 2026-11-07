# checks that vector of names are node attributes in a given network

checks that vector of names are node attributes in a given network

## Usage

``` r
check_node_attributes(g, preds)
```

## Arguments

- g:

  igraph object

- preds:

  vector of node attributes

## Value

error or NULL

## Examples

``` r
check_node_attributes(example_network, c("lat", "site"))
```

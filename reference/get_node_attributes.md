# get node attributes

Remove centrality measures and can filter on cat or num

## Usage

``` r
get_node_attributes(g, type = "all", inc_internals = FALSE)
```

## Arguments

- g:

  network object

- type:

  type to return

- inc_internals:

  boolean to include internals - clusters and centrality

## Value

list of attributes names

## Examples

``` r
get_node_attributes(example_network)
#> [1] "genetic_sex" "site"        "name"        "lat"         "long"       
```

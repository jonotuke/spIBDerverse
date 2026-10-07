# get node attributes

Remove centrality measures and can filter on cat or num

## Usage

``` r
get_node_attributes(g, type = "all", exc_central = TRUE)
```

## Arguments

- g:

  network object

- type:

  type to return

- exc_central:

  boolean to remove centrality measures

## Value

list of attributes names

## Examples

``` r
get_node_attributes(example_network)
#> [1] "genetic_sex" "site"        "name"        "lat"         "long"       
```

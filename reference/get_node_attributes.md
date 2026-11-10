# get node attributes

Remove centrality measures and can filter on cat or num. Attributes with
only one distinct value are dropped, as are categorical attributes with
more than `max_levels` distinct values.

## Usage

``` r
get_node_attributes(
  g,
  type = "all",
  inc_internals = FALSE,
  max_levels = 10,
  trim_levels = TRUE
)
```

## Arguments

- g:

  network object

- type:

  type to return

- inc_internals:

  boolean to include internals - clusters and centrality

- max_levels:

  maximum number of distinct values a categorical attribute can have and
  still be returned. Defaults to `Inf` (no upper limit).

- trim_levels:

  boolean to trim nodes based on max_levels

## Value

list of attributes names

## Examples

``` r
get_node_attributes(example_network)
#> [1] "genetic_sex" "site"        "lat"         "long"       
get_node_attributes(example_network, "cat", max_levels = 10)
#> [1] "genetic_sex" "site"       
```

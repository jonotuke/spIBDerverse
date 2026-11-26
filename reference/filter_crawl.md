# Filter network based on crawl

Filter network based on crawl

## Usage

``` r
filter_crawl(g, levels = c("seed", "crawl", "outside"))
```

## Arguments

- g:

  igraph with .crawl node var

- levels:

  levels to keep

## Value

filter igraph

## Examples

``` r
filter_crawl(example_network, levels = c("seed"))
#> IGRAPH 1bc3b1c UN-- 10 3 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/c), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n),
#> | .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | lat (v/n), long (v/n), .crawl (v/c), wij (e/n), edge_type (e/c)
#> + edges from 1bc3b1c (vertex names):
#> [1] 6--7 1--8 7--9
```

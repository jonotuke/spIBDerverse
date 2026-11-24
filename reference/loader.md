# Load a network

Load a network

## Usage

``` r
loader(edge_file, node_file, crawl_length = 2L)
```

## Arguments

- edge_file:

  edge file

- node_file:

  node file

- crawl_length:

  classifies nodes as seed, in crawl length of outside of crawl length

## Value

igraph object

## Examples

``` r
ibd_file <- system.file("extdata", "example-ibd/example-ibd-data.tsv", package = "spIBDerverse")
meta_file <- system.file("extdata", "example-ibd/example-meta-data.tsv", package = "spIBDerverse")

g <- loader(ibd_file, meta_file)
g
#> IGRAPH 88e8ed1 UN-- 328 4789 -- 
#> + attr: name (v/c), frac_gp (v/n), frac_missing (v/n), frac_het (v/n),
#> | n_cov_snp (v/n), archaeological_id (v/c), master_id (v/c), projects
#> | (v/c), locality (v/c), province (v/c), country (v/c), latitude (v/n),
#> | longitude (v/n), date (v/c), date_type (v/c), imputation_type (v/c),
#> | .degree (v/n), .closeness (v/n), .betweenness (v/n), .eigencentrality
#> | (v/n), .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | .crawl (v/c), max_ibd (e/n), sum_ibd_8 (e/n), n_ibd_8 (e/n),
#> | sum_ibd_12 (e/n), n_ibd_12 (e/n), sum_ibd_16 (e/n), n_ibd_16 (e/n),
#> | sum_ibd_20 (e/n), n_ibd_20 (e/n)
#> + edges from 88e8ed1 (vertex names):
```

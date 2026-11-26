# Load an IBD network

Load an IBD network

## Usage

``` r
load_ibd(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.7,
  crawl_length = 2L
)
```

## Arguments

- ibd_file:

  ibd file

- meta_file:

  meta file

- ibd_co:

  cutoffs for edges

- frac_co:

  quality cutoff

- crawl_length:

  classifies nodes as seed, in crawl length of outside of crawl length

## Value

igraph object

## Examples

``` r
ibd_file <- system.file("extdata", "example-ibd/example-ibd-data.tsv", package = "spIBDerverse")
meta_file <- system.file("extdata", "example-ibd/example-meta-data.tsv", package = "spIBDerverse")

g <- load_ibd(ibd_file, meta_file)
g
#> IGRAPH 1e5745f UN-- 328 1712 -- 
#> + attr: name (v/c), frac_gp (v/n), frac_missing (v/n), frac_het (v/n),
#> | n_cov_snp (v/n), Archaeological_ID (v/c), Master_ID (v/c), Projects
#> | (v/c), Locality (v/c), Province (v/c), Country (v/c), Latitude (v/n),
#> | Longitude (v/n), date (v/c), date_type (v/c), imputation_type (v/c),
#> | .degree (v/n), .closeness (v/n), .betweenness (v/n), .eigencentrality
#> | (v/n), .louvain (v/c), .louvain_weighted (v/c), .eigen (v/c),
#> | .eigen_weighted (v/c), .label_prop (v/c), .label_prop_weighted (v/c),
#> | .crawl (v/c), frac_gp1 (e/n), frac_gp2 (e/n), max_ibd (e/n),
#> | sum_ibd_8 (e/n), n_ibd_8 (e/n), sum_ibd_12 (e/n), n_ibd_12 (e/n),
#> | sum_ibd_16 (e/n), n_ibd_16 (e/n), sum_ibd_20 (e/n), n_ibd_20 (e/n),
#> | wij (e/n)
#> + edges from 1e5745f (vertex names):
```

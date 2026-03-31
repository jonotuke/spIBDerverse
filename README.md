
<!-- README.md is generated from README.Rmd. Please edit that file -->

# spIBDerverse

<!-- badges: start -->

[![R-CMD-check](https://github.com/jonotuke/spIBDerverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jonotuke/spIBDerverse/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of spIBDerverse is to give a series of function to apply ERGMs
to IBD networks.

## Installation

You can install the development version of spIBDerverse from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("jonotuke/spIBDerverse")
```

## Example

``` r
library(spIBDerverse)
```

# Data

The fundemental object for the `spIBDerverse` package is the IBD
network. You are create this using two `TSV` files.

## IBD dataset (edge info)

The first file is the IBD file. It should have the following headers.

    #> -  iid1 
    #> -  iid2 
    #> -  max_IBD 
    #> -  sum_IBD>8 
    #> -  n_IBD>8 
    #> -  sum_IBD>12 
    #> -  n_IBD>12 
    #> -  sum_IBD>16 
    #> -  n_IBD>16 
    #> -  sum_IBD>20 
    #> -  n_IBD>20

## Meta dataset (node info)

The next file needed is the meta file. This can contain any meta-data
about the samples, but needs two columns:

1.  `iid` this has the sample IDs and must have an entry for each of the
    IDs mentioned in the `iid1` and `iid2` column of the IBD file.
2.  A `frac_gp` column.

## Creating the IBD network.

There are example files within the `spIBDerverse` package that can be
used as an example. These can be obtained with

``` r
ibd_file <- fs::path_package(
  "extdata",
  "example-ibd-data.tsv",
  package = "spIBDerverse"
)
meta_file <- fs::path_package(
  "extdata",
  "example-meta-data.tsv",
  package = "spIBDerverse"
)
```

We convert these to an IBD network with

``` r
ibd_network <- load_ibd_network(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.49
)
```

``` r
ibd_network
#> IGRAPH 3a96b2a UN-- 328 2103 -- 
#> + attr: name (v/c), frac_gp (v/n), frac_missing (v/n), frac_het (v/n),
#> | n_cov_snp (v/n), Archaeological_ID (v/c), Master_ID (v/c), Projects
#> | (v/c), Locality (v/c), Province (v/c), Country (v/c), Latitude (v/n),
#> | Longitude (v/n), date (v/c), date_type (v/c), imputation_type (v/c),
#> | degree (v/n), closeness (v/n), betweenness (v/n), eigencentrality
#> | (v/n), frac_gp1 (e/n), frac_gp2 (e/n), max_ibd (e/n), sum_ibd_8
#> | (e/n), n_ibd_8 (e/n), sum_ibd_12 (e/n), n_ibd_12 (e/n), sum_ibd_16
#> | (e/n), n_ibd_16 (e/n), sum_ibd_20 (e/n), n_ibd_20 (e/n), wij (e/n)
#> + edges from 3a96b2a (vertex names):
#> [1] KUP007--KUP023 RKC013--RKC029 RKC031--RKF238 RKF195--RKF196 RKC020--RKF142
#> + ... omitted several edges
```

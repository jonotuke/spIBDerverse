# create_ibd_network

create_ibd_network

## Usage

``` r
create_ibd_network(ibd_file, meta_file, ibd_co, frac_co = 0.7)
```

## Arguments

- ibd_file:

  TSV file with IBD data

- meta_file:

  TSV with node metadata

- ibd_co:

  vector of cutoffs for defining an edge

- frac_co:

  cutoff for quality control - default is 0.49

## Value

IBD network

## Examples

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
create_ibd_network(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0)
)
#> IGRAPH de593c3 UN-- 328 1712 -- 
#> + attr: name (v/c), frac_gp (v/n), frac_missing (v/n), frac_het (v/n),
#> | n_cov_snp (v/n), Archaeological_ID (v/c), Master_ID (v/c), Projects
#> | (v/c), Locality (v/c), Province (v/c), Country (v/c), Latitude (v/n),
#> | Longitude (v/n), date (v/c), date_type (v/c), imputation_type (v/c),
#> | degree (v/n), wij (e/n)
#> + edges from de593c3 (vertex names):
#>  [1] KUP007--KUP023 RKC013--RKC029 RKC031--RKF238 RKF195--RKF196 RKC020--RKF142
#>  [6] KFJ018--KFJ017 RKF182--RKF148 RKF142--RKF002 RKF162--RKF118 RKC011--RKC029
#> [11] RKF052--RKF172 KFJ021--KFJ010 KFJ012--KFJ009 RKF143--RKF034 RKF237--RKF136
#> [16] KFJ022--KFJ009 RKF026--RKF027 RKF142--RKF140 RKF254--RKF256 RKF160--RKF047
#> + ... omitted several edges
```

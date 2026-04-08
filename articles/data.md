# Loading data into SpIBDerverse app

``` r
library(spIBDerverse)
library(igraph)
```

In the spIBDerverse app, there are three ways to get data into the app.

## Load examples

Built into the `spIBDerverse` package are numerous example neworks that
can be loaded into the app using the `load_examples()` function.

``` r
example <- load_example()
example
#> IGRAPH 22f3232 UN-- 40 110 -- 
#> + attr: genetic_sex (v/c), site (v/c), name (v/n), .degree (v/n),
#> | .closeness (v/n), .betweenness (v/n), .eigencentrality (v/n), lat
#> | (v/n), long (v/n), wij (e/n), edge_type (e/c)
#> + edges from 22f3232 (vertex names):
#>  [1]  1-- 9  1--13  1--14  1--15  1--17  1--19  1--20  1--25  1--28  2-- 5
#> [11]  2--14  2--24  2--26  2--28  2--36  3-- 4  3-- 6  3--16  3--24  3--34
#> [21]  3--39  4-- 8  4--10  4--14  4--27  4--30  4--36  4--37  5-- 7  5-- 9
#> [31]  5--11  5--15  5--20  5--25  5--31  5--33  7-- 9  7--12  7--13  7--23
#> [41]  7--25  7--38  8--14  9--10  9--11  9--16  9--23  9--25  9--26  9--38
#> [51] 10--34 10--38 10--40 11--12 11--29 11--33 11--40 12--29 12--32 12--33
#> + ... omitted several edges
```

It will return a message if you ask for a dataset that does not exist.

``` r
load_example("bob")
#> That data does not exist
#> NULL
```

## Load an IBD network

This will use two files:

- an IBD file which gives the edges, and
- an META file which has node information:

``` r
ibd_file <- fs::path_package(
  "extdata/example-ibd-data.tsv",
  package = "spIBDerverse"
)
ibd_file |> readr::read_tsv() |> dplyr::slice(1:5)
#> Rows: 4789 Columns: 11
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr (2): iid1, iid2
#> dbl (9): max_IBD, sum_IBD>8, n_IBD>8, sum_IBD>12, n_IBD>12, sum_IBD>16, n_IB...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 5 × 11
#>   iid1  iid2  max_IBD `sum_IBD>8` `n_IBD>8` `sum_IBD>12` `n_IBD>12` `sum_IBD>16`
#>   <chr> <chr>   <dbl>       <dbl>     <dbl>        <dbl>      <dbl>        <dbl>
#> 1 KUP0… KUP0…    284.       3403.        22        3403.         22        3403.
#> 2 RKC0… RKC0…    284.       3399.        23        3399.         23        3399.
#> 3 RKF2… RKC0…    269.       3394.        22        3394.         22        3394.
#> 4 RKF1… RKF1…    284.       3390.        22        3390.         22        3390.
#> 5 RKF1… RKC0…    284.       3389.        23        3389.         23        3389.
#> # ℹ 3 more variables: `n_IBD>16` <dbl>, `sum_IBD>20` <dbl>, `n_IBD>20` <dbl>
```

``` r
meta_file <- fs::path_package(
  "extdata/example-meta-data.tsv",
  package = "spIBDerverse"
)
meta_file |> readr::read_tsv() |> dplyr::slice(1:5)
#> Rows: 328 Columns: 16
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr (10): iid, Archaeological_ID, Master_ID, Projects, Locality, Province, C...
#> dbl  (6): frac_gp, frac_missing, frac_het, n_cov_snp, Latitude, Longitude
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 5 × 16
#>   iid    frac_gp frac_missing frac_het n_cov_snp Archaeological_ID Master_ID
#>   <chr>    <dbl>        <dbl>    <dbl>     <dbl> <chr>             <chr>    
#> 1 RKO006   0.953       0.0340    0.269   1154253 190/388           RKO006   
#> 2 RKO002   0.953       0.0340    0.269   1043584 331/441           RKO002   
#> 3 RKF270   0.951       0.0340    0.260    891830 621/746           RKF270   
#> 4 RKF273   0.932       0.0340    0.271    831942 623/748           RKF273   
#> 5 RKO003   0.927       0.0340    0.271    939881 543/669           RKO003   
#> # ℹ 9 more variables: Projects <chr>, Locality <chr>, Province <chr>,
#> #   Country <chr>, Latitude <dbl>, Longitude <dbl>, date <chr>,
#> #   date_type <chr>, imputation_type <chr>
```

The IBD file must have two columns `iid1` and `iid2` else you can not
create the IBD network, while the META file must have a column called
`iid`.

``` r
load_ibd_network(ibd_file, meta_file)
#> IGRAPH 3fd5377 UN-- 328 1712 -- 
#> + attr: name (v/c), frac_gp (v/n), frac_missing (v/n), frac_het (v/n),
#> | n_cov_snp (v/n), Archaeological_ID (v/c), Master_ID (v/c), Projects
#> | (v/c), Locality (v/c), Province (v/c), Country (v/c), Latitude (v/n),
#> | Longitude (v/n), date (v/c), date_type (v/c), imputation_type (v/c),
#> | .degree (v/n), .closeness (v/n), .betweenness (v/n), .eigencentrality
#> | (v/n), frac_gp1 (e/n), frac_gp2 (e/n), max_ibd (e/n), sum_ibd_8
#> | (e/n), n_ibd_8 (e/n), sum_ibd_12 (e/n), n_ibd_12 (e/n), sum_ibd_16
#> | (e/n), n_ibd_16 (e/n), sum_ibd_20 (e/n), n_ibd_20 (e/n), wij (e/n)
#> + edges from 3fd5377 (vertex names):
#> [1] KUP007--KUP023 RKC013--RKC029 RKC031--RKF238 RKF195--RKF196 RKC020--RKF142
#> + ... omitted several edges
```

## Load distance network

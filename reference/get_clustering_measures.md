# get clustering measures

get clustering measures

## Usage

``` r
get_clustering_measures(g, pred = "none", cluster = ".louvain")
```

## Arguments

- g:

  igraph object with clustering

- pred:

  pred to stratify on. If "none" returns clustering for all nodes

- cluster:

  clustering measure

## Value

table of clustering

## See also

[`plot_clustering_confusion()`](https://jonotuke.github.io/spIBDerverse/reference/plot_clustering_confusion.md)
for a heatmap of the categorical-predictor table.

## Examples

``` r
get_clustering_measures(example_network)
#> # A tibble: 40 × 11
#>    genetic_sex site  name    lat  long Louvain `Weighted Louvain`
#>    <chr>       <chr> <chr> <dbl> <dbl> <chr>   <chr>             
#>  1 F           C     1     -34.8  139. L1      Lw1               
#>  2 M           C     2     -34.8  139. L2      Lw2               
#>  3 M           B     3     -34.9  139. L2      Lw2               
#>  4 F           C     4     -34.8  139. L1      Lw1               
#>  5 F           C     5     -34.8  139. L1      Lw1               
#>  6 F           B     6     -34.9  139. L2      Lw2               
#>  7 F           B     7     -34.9  139. L3      Lw3               
#>  8 M           A     8     -34.9  139. L4      Lw2               
#>  9 F           C     9     -34.8  139. L1      Lw1               
#> 10 M           A     10    -34.9  139. L4      Lw4               
#> # ℹ 30 more rows
#> # ℹ 4 more variables: `Leading eigenvalue` <chr>,
#> #   `Weighted leading eigenvalue` <chr>, `Label propagation` <chr>,
#> #   `Weighted label propagation` <chr>
```

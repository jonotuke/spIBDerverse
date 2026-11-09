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
#> # A tibble: 40 × 10
#>    genetic_sex site    lat  long Louvain `Weighted Louvain` `Leading eigenvalue`
#>    <chr>       <chr> <dbl> <dbl> <chr>   <chr>              <chr>               
#>  1 F           C     -34.8  139. L1      Lw1                E1                  
#>  2 M           C     -34.8  139. L2      Lw2                E2                  
#>  3 M           B     -34.9  139. L2      Lw2                E2                  
#>  4 F           C     -34.8  139. L1      Lw1                E1                  
#>  5 F           C     -34.8  139. L1      Lw1                E1                  
#>  6 F           B     -34.9  139. L2      Lw2                E3                  
#>  7 F           B     -34.9  139. L3      Lw3                E3                  
#>  8 M           A     -34.9  139. L4      Lw2                E5                  
#>  9 F           C     -34.8  139. L1      Lw1                E1                  
#> 10 M           A     -34.9  139. L4      Lw4                E5                  
#> # ℹ 30 more rows
#> # ℹ 3 more variables: `Weighted leading eigenvalue` <chr>,
#> #   `Label propagation` <chr>, `Weighted label propagation` <chr>
```

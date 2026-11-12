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
#>  1 F           B     -34.9  139. L1      Lw1                E1                  
#>  2 M           C     -34.8  139. L2      Lw2                E2                  
#>  3 M           C     -34.8  139. L2      Lw2                E2                  
#>  4 F           B     -34.9  139. L1      Lw1                E1                  
#>  5 F           C     -34.8  139. L2      Lw3                E2                  
#>  6 F           B     -34.9  139. L1      Lw4                E1                  
#>  7 M           B     -34.9  139. L3      Lw5                E3                  
#>  8 M           C     -34.8  139. L2      Lw2                E2                  
#>  9 M           B     -34.9  139. L3      Lw4                E2                  
#> 10 M           C     -34.8  139. L2      Lw5                E2                  
#> # ℹ 30 more rows
#> # ℹ 3 more variables: `Weighted leading eigenvalue` <chr>,
#> #   `Label propagation` <chr>, `Weighted label propagation` <chr>
```

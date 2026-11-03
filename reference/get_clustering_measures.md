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

## Examples

``` r
get_clustering_measures(example_network)
#> # A tibble: 40 × 11
#>    genetic_sex site  name    lat  long Louvain `Weighted Louvain`
#>    <chr>       <chr> <chr> <dbl> <dbl> <chr>   <chr>             
#>  1 F           A     1     -34.9  139. 1       1                 
#>  2 F           B     2     -34.9  139. 2       2                 
#>  3 M           A     3     -34.9  139. 2       3                 
#>  4 F           A     4     -34.9  139. 2       2                 
#>  5 M           A     5     -34.9  139. 2       3                 
#>  6 M           B     6     -34.9  139. 2       3                 
#>  7 M           A     7     -34.9  139. 3       1                 
#>  8 M           B     8     -34.9  139. 2       3                 
#>  9 F           B     9     -34.9  139. 2       2                 
#> 10 F           B     10    -34.9  139. 2       2                 
#> # ℹ 30 more rows
#> # ℹ 4 more variables: `Leading eigenvalue` <chr>,
#> #   `Weighted leading eigenvalue` <chr>, `Label propagation` <chr>,
#> #   `Weighted label propagation` <chr>
```

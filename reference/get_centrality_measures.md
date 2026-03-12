# Get centrality measures

Gives a table of mean centrality measures given a list of vertex
attributes to stratify on. If not list given then gives overall.

## Usage

``` r
get_centrality_measures(g, var = NULL)
```

## Arguments

- g:

  igraph object

- var:

  character vector of attributes to stratify on

## Value

tibble of centrality measures

## Examples

``` r
get_centrality_measures(example_network, c("site", "genetic_sex"))
#> # A tibble: 6 × 7
#>   site  genetic_sex nodes degree closeness betweenness eigen_centrality
#>   <chr> <chr>       <dbl>  <dbl>     <dbl>       <dbl>            <dbl>
#> 1 A     F               4   3.25   0.00903        25.0           0.0759
#> 2 A     M              11   5.18   0.0109         26.7           0.245 
#> 3 B     F               5   4.4    0.0102         26.2           0.168 
#> 4 B     M               8   6.25   0.0112         30.2           0.289 
#> 5 C     F               7   7.29   0.0108         17.7           0.769 
#> 6 C     M               5   8.6    0.0120         42.1           0.767 
```

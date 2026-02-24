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
#> 1 A     F               7   3.57   0.00992        19.7           0.199 
#> 2 A     M               7   4      0.00981        17.4           0.0872
#> 3 B     F               5   4      0.0101         21.6           0.163 
#> 4 B     M               7   4.71   0.00998        23.9           0.124 
#> 5 C     F              10   8.7    0.0119         38.7           0.755 
#> 6 C     M               4   7.25   0.0121         51.7           0.491 
```

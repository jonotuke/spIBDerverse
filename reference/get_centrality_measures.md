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
#> # A tibble: 6 × 6
#>   site  genetic_sex degree closeness betweenness eigen_centrality
#>   <chr> <chr>        <dbl>     <dbl>       <dbl>            <dbl>
#> 1 A     F             3.57   0.00992        19.7           0.199 
#> 2 A     M             4      0.00981        17.4           0.0872
#> 3 B     F             4      0.0101         21.6           0.163 
#> 4 B     M             4.71   0.00998        23.9           0.124 
#> 5 C     F             8.7    0.0119         38.7           0.755 
#> 6 C     M             7.25   0.0121         51.7           0.491 
```

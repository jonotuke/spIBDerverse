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
#>   site  genetic_sex nodes .degree .closeness .betweenness .eigencentrality
#>   <chr> <chr>       <dbl>   <dbl>      <dbl>        <dbl>            <dbl>
#> 1 A     F               8    3.88    0.0104         14.5             0.167
#> 2 A     M               6    2       0.00880         7.84            0.109
#> 3 B     F               7    5.43    0.0112         22.6             0.286
#> 4 B     M               4    5.75    0.0111         25.4             0.282
#> 5 C     F               9    9.44    0.0127         43.3             0.773
#> 6 C     M               6    9.5     0.0127         38.4             0.816
```

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
#> 1 A     F               8    3.88    0.00986         19.1            0.335
#> 2 A     M              11    5.82    0.0112          31.1            0.639
#> 3 B     F               4    4       0.00942         26.5            0.339
#> 4 B     M               9    5.44    0.0107          34.2            0.602
#> 5 C     F               4    6       0.0105          34.6            0.545
#> 6 C     M               4    5       0.0102          28.3            0.458
```

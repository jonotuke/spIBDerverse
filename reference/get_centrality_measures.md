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
#> 1 A     F               5    2.8     0.00941         10.8            0.168
#> 2 A     M              11    4.45    0.0101          21.7            0.316
#> 3 B     F               8    6.12    0.0110          38.5            0.370
#> 4 B     M               4    3.75    0.0101          16.8            0.268
#> 5 C     F               6    7       0.0115          27.6            0.622
#> 6 C     M               6    8.5     0.0122          47.6            0.829
```

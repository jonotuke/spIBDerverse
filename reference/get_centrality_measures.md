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
#> 1 A     F               4    5        0.0115         24.8            0.246
#> 2 A     M              10    5.7      0.0116         17.5            0.334
#> 3 B     F               6    5        0.0103         17.8            0.186
#> 4 B     M               6    7.67     0.0121         24.6            0.461
#> 5 C     F               6    7        0.0121         26.6            0.418
#> 6 C     M               8    8.88     0.0128         31.7            0.697
```

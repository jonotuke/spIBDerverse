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
#> 1 A     F               6    3       0.0101         20.9             0.176
#> 2 A     M               5    3       0.00979         7.94            0.229
#> 3 B     F              10    6.7     0.0113         29.6             0.426
#> 4 B     M               5    3.6     0.0101         13.8             0.179
#> 5 C     F               6    6.67    0.0121         34.5             0.523
#> 6 C     M               8    9       0.0124         39.6             0.792
```

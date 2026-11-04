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
#> 1 A     F               4    2.75    0.00876         7.43            0.112
#> 2 A     M               9    4.67    0.0102          9.72            0.165
#> 3 B     F               6    5.33    0.0112         39.4             0.263
#> 4 B     M               6    7.33    0.0119         31.6             0.318
#> 5 C     F              10    9.4     0.0120         27.1             0.834
#> 6 C     M               5    9       0.0127         44.2             0.552
```

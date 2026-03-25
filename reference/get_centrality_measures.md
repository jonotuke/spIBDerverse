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
#>   site  genetic_sex nodes degree closeness betweenness eigencentrality
#>   <chr> <chr>       <dbl>  <dbl>     <dbl>       <dbl>           <dbl>
#> 1 A     F               6   3      0.00906        20.3           0.133
#> 2 A     M              11   4.82   0.0104         22.5           0.489
#> 3 B     F               3   4.67   0.0101         27.4           0.270
#> 4 B     M              10   5.7    0.0110         33.8           0.550
#> 5 C     F               5   4.6    0.00987        26.2           0.273
#> 6 C     M               5   6.6    0.0115         48.4           0.651
```

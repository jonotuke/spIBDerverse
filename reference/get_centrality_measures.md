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
#> 1 A     F               8    3.25    0.00936        26.4             0.102
#> 2 A     M               8    2.5     0.00891         9.90            0.127
#> 3 B     F               4    5       0.0103         37.0             0.167
#> 4 B     M               5    4.2     0.00975        23.3             0.158
#> 5 C     F               7    7.43    0.0115         44.1             0.618
#> 6 C     M               8    8.62    0.0117         44.3             0.762
```

# get_network_measures

get_network_measures

## Usage

``` r
get_network_measures(g, measure = "degree", var = "")
```

## Arguments

- g:

  igraph object

- measure:

  centrality measure to use

- var:

  vertex variables to stratify on

## Value

summary table

## Examples

``` r
get_network_measures(example_network, var = "site")
#> # A tibble: 3 × 2
#>   site  `mean (degree)`
#>   <chr>           <dbl>
#> 1 A                3.79
#> 2 B                4.42
#> 3 C                8.29
```

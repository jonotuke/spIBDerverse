# Get network summary

Get network summary

## Usage

``` r
get_network_summary(g)
```

## Arguments

- g:

  ibd network

## Value

tibble with summary info on network

## Examples

``` r
get_network_summary(example_network)
#> # A tibble: 7 × 2
#>   measure                              value
#>   <chr>                                <dbl>
#> 1 Number of nodes                         40
#> 2 Number of edges                        111
#> 3 Number of unconnected nodes              0
#> 4 Number of nodes missing: genetic_sex     0
#> 5 Number of nodes missing: site            0
#> 6 Number of nodes missing: lat             0
#> 7 Number of nodes missing: long            0
```

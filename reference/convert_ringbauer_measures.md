# Convert ringbauer measures

This converts the ringbauer measures into matrices of the correct form
for the plot function.

## Usage

``` r
convert_ringbauer_measures(
  RM,
  abbr = TRUE,
  addSize = FALSE,
  addPercent = FALSE
)
```

## Arguments

- RM:

  A ringbauer measure tibble

- abbr:

  a boolean that when true will shorten the group names

- addSize:

  adds size to group labels

- addPercent:

  add percent to labels

## Value

a list of three matrices: density, labels, and text colour

## Examples

``` r
get_ringbauer_measures(example_network, "site") |>
convert_ringbauer_measures()
#> $density
#>            C          B          A
#> C 0.57575758 0.05128205 0.05555556
#> B 0.05128205 0.26923077 0.11282051
#> A 0.05555556 0.11282051 0.18095238
#> 
#> $labels
#>   C        B        A       
#> C "38/66"  "8/156"  "10/180"
#> B "8/156"  "21/78"  "22/195"
#> A "10/180" "22/195" "19/105"
#> 
#> $text_colour
#>   C       B       A      
#> C "black" "white" "white"
#> B "white" "white" "white"
#> A "white" "white" "white"
#> 
```

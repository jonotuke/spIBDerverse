# Convert ringbauer measures

This converts the ringbauer measures into matrices of the correct form
for the plot function.

## Usage

``` r
convert_ringbauer_measures(
  RM,
  abbr = FALSE,
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
#>            A          B          C
#> A 0.14166667 0.07291667 0.07812500
#> B 0.07291667 0.27272727 0.09722222
#> C 0.07812500 0.09722222 0.48484848
#> 
#> $labels
#>   A        B        C       
#> A "17/120" "14/192" "15/192"
#> B "14/192" "18/66"  "14/144"
#> C "15/192" "14/144" "32/66" 
#> 
#> $text_colour
#>   A       B       C      
#> A "white" "white" "white"
#> B "white" "black" "white"
#> C "white" "white" "black"
#> 
```

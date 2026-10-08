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
#> Warning: Chi-squared approximation may be incorrect
#> $density
#>            A          C          B
#> A 0.10833333 0.05000000 0.05555556
#> C 0.05000000 0.47619048 0.06666667
#> B 0.05555556 0.06666667 0.33333333
#> 
#> $labels
#>   A        C        B      
#> A "13/120" "12/240" "8/144"
#> C "12/240" "50/105" "9/135"
#> B "8/144"  "9/135"  "12/36"
#> 
#> $text_colour
#>   A       C       B      
#> A "white" "white" "white"
#> C "white" "black" "white"
#> B "white" "white" "black"
#> 
```

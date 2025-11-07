# Convert ringbauer measures

This converts the ringbauer measures into matrices of the correct form
for the plot function.

## Usage

``` r
convert_ringbauer_measures(RM, abbr = TRUE)
```

## Arguments

- RM:

  A ringbauer measure tibble

- abbr:

  a boolean that when true will shorten the group names

## Value

a list of three matrices: density, labels, and text colour

## Examples

``` r
get_ringbauer_measures(example_network, "site") |>
convert_ringbauer_measures()
#> $density
#>            A          C          B
#> A 0.16483516 0.07653061 0.04761905
#> C 0.07653061 0.50549451 0.05357143
#> B 0.04761905 0.05357143 0.27272727
#> 
#> $labels
#>   A        C        B      
#> A "15/91"  "15/196" "8/168"
#> C "15/196" "46/91"  "9/168"
#> B "8/168"  "9/168"  "18/66"
#> 
#> $text_colour
#>   A       C       B      
#> A "white" "white" "white"
#> C "white" "black" "white"
#> B "white" "white" "black"
#> 
```

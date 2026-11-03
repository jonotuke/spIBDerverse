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
#> A 0.23076923 0.10119048 0.09183673
#> B 0.10119048 0.36363636 0.06547619
#> C 0.09183673 0.06547619 0.46153846
#> 
#> $labels
#>   A        B        C       
#> A "21/91"  "17/168" "18/196"
#> B "17/168" "24/66"  "11/168"
#> C "18/196" "11/168" "42/91" 
#> 
#> $text_colour
#>   A       B       C      
#> A "white" "white" "white"
#> B "white" "black" "white"
#> C "white" "white" "black"
#> 
```

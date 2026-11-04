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
#>            C          B          A
#> C 0.52380952 0.10909091 0.06666667
#> B 0.10909091 0.32727273 0.04545455
#> A 0.06666667 0.04545455 0.12087912
#> 
#> $labels
#>   C        B        A       
#> C "55/105" "18/165" "14/210"
#> B "18/165" "18/55"  "7/154" 
#> A "14/210" "7/154"  "11/91" 
#> 
#> $text_colour
#>   C       B       A      
#> C "black" "white" "white"
#> B "white" "black" "white"
#> A "white" "white" "white"
#> 
```

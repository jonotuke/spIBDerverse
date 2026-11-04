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
#> C 0.52380952 0.10000000 0.05641026
#> B 0.10000000 0.33333333 0.08974359
#> A 0.05641026 0.08974359 0.17948718
#> 
#> $labels
#>   C        B        A       
#> C "55/105" "18/180" "11/195"
#> B "18/180" "22/66"  "14/156"
#> A "11/195" "14/156" "14/78" 
#> 
#> $text_colour
#>   C       B       A      
#> C "black" "white" "white"
#> B "white" "black" "white"
#> A "white" "white" "white"
#> 
```

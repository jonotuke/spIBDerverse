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
#>            C          A          B
#> C 0.40000000 0.06470588 0.06923077
#> A 0.06470588 0.14705882 0.09049774
#> B 0.06923077 0.09049774 0.26923077
#> 
#> $labels
#>   C        A        B       
#> C "18/45"  "11/170" "9/130" 
#> A "11/170" "20/136" "20/221"
#> B "9/130"  "20/221" "21/78" 
#> 
#> $text_colour
#>   C       A       B      
#> C "black" "white" "white"
#> A "white" "white" "white"
#> B "white" "white" "black"
#> 
```

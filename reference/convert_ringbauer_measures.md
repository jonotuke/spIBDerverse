# Convert ringbauer measures

Converts the ringbauer measures into matrices.
[`plot_ringbauer()`](https://jonotuke.github.io/spIBDerverse/reference/plot_ringbauer.md)
no longer needs this step, as it takes the output of
[`get_ringbauer_measures()`](https://jonotuke.github.io/spIBDerverse/reference/get_ringbauer_measures.md)
directly; this is kept for code that uses the matrices themselves.

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
#>            B          C          A
#> B 0.30476190 0.06190476 0.04848485
#> C 0.06190476 0.46153846 0.09740260
#> A 0.04848485 0.09740260 0.09090909
#> 
#> $labels
#>   B        C        A       
#> B "32/105" "13/210" "8/165" 
#> C "13/210" "42/91"  "15/154"
#> A "8/165"  "15/154" "5/55"  
#> 
#> $text_colour
#>   B       C       A      
#> B "black" "white" "white"
#> C "white" "black" "white"
#> A "white" "white" "white"
#> 
```

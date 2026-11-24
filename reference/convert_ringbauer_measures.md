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
#> Warning: There was 1 warning in `dplyr::mutate()`.
#> ℹ In argument: `prop_test = purrr::map2(...)`.
#> Caused by warning in `stats::prop.test()`:
#> ! Chi-squared approximation may be incorrect
#> $density
#>            A          B          C
#> A 0.20467836 0.06477733 0.05921053
#> B 0.06477733 0.28205128 0.04807692
#> C 0.05921053 0.04807692 0.53571429
#> 
#> $labels
#>   A        B        C      
#> A "35/171" "16/247" "9/152"
#> B "16/247" "22/78"  "5/104"
#> C "9/152"  "5/104"  "15/28"
#> 
#> $text_colour
#>   A       B       C      
#> A "white" "white" "white"
#> B "white" "black" "white"
#> C "white" "white" "black"
#> 
```

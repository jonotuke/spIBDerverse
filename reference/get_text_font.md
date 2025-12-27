# Get text font

Used to get contrasting text to a fill.

## Usage

``` r
get_text_font(x, type = "fill")
```

## Arguments

- x:

  numeric vector to convert to colour

- type:

  whether to return the colour, or black / white for text

## Value

vector of colours

## Examples

``` r
get_text_font(1:10)
#>  [1] "#440154FF" "#482878FF" "#3E4A89FF" "#31688EFF" "#26838EFF" "#1F9D89FF"
#>  [7] "#35B779FF" "#6CCE59FF" "#B4DD2CFF" "#FDE725FF"
get_text_font(1:10, "text")
#>  [1] "white" "white" "white" "white" "black" "black" "black" "black" "black"
#> [10] "black"
```

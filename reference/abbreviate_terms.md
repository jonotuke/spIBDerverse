# abbreviate labels

Takes first letter of each word, where a word is separated by space on
hyphen Also removes brackets first

## Usage

``` r
abbreviate_terms(x)
```

## Arguments

- x:

  vector of labels

## Value

vector of abbreviations

## Examples

``` r
abbreviate_terms(c("Jono Tuke", "Adam Ben Rohrlach", "Adelaide-University"))
#> [1] "JT"  "ABR" "AU" 
```

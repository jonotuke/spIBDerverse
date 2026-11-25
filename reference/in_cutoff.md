# check if values are in cutoffs

check if values are in cutoffs

## Usage

``` r
in_cutoff(values, cutoff)
```

## Arguments

- values:

  vector of values

- cutoff:

  endpoints for numeric, values for categorical

## Value

boolean vector

## Examples

``` r
in_cutoff(1:10, c(NA, 5))
#>  [1]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
```

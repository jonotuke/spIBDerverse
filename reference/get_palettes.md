# List ggsci palettes

Finds every `scale_fill_*()` function exported by the installed version
of ggsci, so the list stays current when ggsci is updated.

## Usage

``` r
get_palettes()
```

## Value

a data frame with the palette name (the value to pass as `pal`), whether
it is discrete or continuous

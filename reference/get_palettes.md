# List available palettes

Finds every `scale_fill_*()` function exported by the installed version
of ggsci, so the list stays current when ggsci is updated. Also includes
`"default"`, which gives ggplot2's own default scale and works for both
discrete and continuous data.

Finds every `scale_fill_*()` function exported by the installed version
of ggsci, so the list stays current when ggsci is updated. Also includes
`"default"`, which gives ggplot2's own default scale and works for both
discrete and continuous data.

## Usage

``` r
get_palettes()

get_palettes()
```

## Value

a data frame with the palette name (the value to pass as `pal`), whether
it is discrete, continuous or both

a data frame with the palette name (the value to pass as `pal`), whether
it is discrete, continuous or both

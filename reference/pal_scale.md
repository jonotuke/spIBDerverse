# Build a palette scale by name

Internal helper that looks up `scale_<aesthetic>_<pal>()` in ggsci and
calls it, so any palette in your installed version of ggsci can be used.
Use `pal = "default"` to get ggplot2's default discrete or continuous
scale instead.

Internal helper that looks up `scale_<aesthetic>_<pal>()` in ggsci and
calls it, so any palette in your installed version of ggsci can be used.
Use `pal = "default"` to get ggplot2's default discrete or continuous
scale instead.

## Usage

``` r
pal_scale(aesthetic, pal, type = "discrete", ...)

pal_scale(aesthetic, pal, type = "discrete", ...)
```

## Arguments

- aesthetic:

  "fill" or "colour"/"color"

- pal:

  ggsci palette name, e.g. "npg", "lancet", "gsea", or "default" for the
  ggplot2 default

- type:

  "discrete" or "continuous". For ggsci palettes this is used for
  validation only; for `pal = "default"` it picks which ggplot2 scale to
  use.

- ...:

  passed on to the scale (e.g. `palette = "category20"`, `alpha = 0.8`,
  `reverse = TRUE` for ggsci; any ggplot2 scale argument such as `name`
  or `limits` for the default)

## Value

a ggplot2 scale

a ggplot2 scale

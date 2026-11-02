# Build a ggsci scale by name

Internal helper that looks up `scale_<aesthetic>_<pal>()` in ggsci and
calls it, so any palette in your installed version of ggsci can be used.

## Usage

``` r
pal_scale(aesthetic, pal, type = "discrete", ...)
```

## Arguments

- aesthetic:

  "fill" or "color"

- pal:

  ggsci palette name, e.g. "npg", "lancet", "gsea"

- type:

  "discrete" or "continuous" (used for validation only)

- ...:

  passed on to the ggsci scale (e.g. `palette = "category20"`,
  `alpha = 0.8`, `reverse = TRUE`)

## Value

a ggplot2 scale

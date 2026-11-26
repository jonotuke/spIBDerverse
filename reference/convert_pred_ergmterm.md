# convert_pred_terms

convert_pred_terms

## Usage

``` r
convert_pred_ergmterm(pred, type, ref)
```

## Arguments

- pred:

  name of igraph vertex attribute

- type:

  ergm term type

- ref:

  ref level

## Value

ergm term for attribute based on class

## Examples

``` r
convert_pred_ergmterm("site", "nodecov", -1)
#> [1] "nodecov('site')"
```

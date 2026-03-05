# convert_pred_terms

convert_pred_terms

## Usage

``` r
convert_pred_ergmterm(pred, type)
```

## Arguments

- pred:

  name of igraph vertex attribute

- type:

  ergm term type

## Value

ergm term for attribute based on class

## Examples

``` r
convert_pred_ergmterm("site", "nodecov")
#> [1] "nodecov('site')"
```

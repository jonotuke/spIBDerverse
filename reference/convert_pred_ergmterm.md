# convert_pred_terms

convert_pred_terms

## Usage

``` r
convert_pred_ergmterm(pred, g)
```

## Arguments

- pred:

  name of igraph vertex attribute

- g:

  igraph object

## Value

ergm term for attribute based on class

## Examples

``` r
convert_pred_ergmterm("site", example_network)
#> nodemix('site')
```

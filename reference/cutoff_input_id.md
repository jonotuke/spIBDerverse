# Input id for the cutoff control of one attribute

Attribute names can contain characters that are not valid in input ids,
so they are sanitised here.

## Usage

``` r
cutoff_input_id(x, what = c("node", "edge"))
```

## Arguments

- x:

  Attribute name.

- what:

  Either `"node"` or `"edge"`.

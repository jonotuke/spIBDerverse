# Build the cutoff input for a node or edge attribute

Numeric attributes get a range input spanning the observed values;
everything else gets a checkbox group of the distinct values.

## Usage

``` r
make_cutoff_ui(id, x, g, what = c("node", "edge"))
```

## Arguments

- id:

  Module id.

- x:

  Name of the attribute to filter on, or `"none"`.

- g:

  An igraph object.

- what:

  Either `"node"` or `"edge"`.

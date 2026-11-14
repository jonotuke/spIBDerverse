# Build the cutoff input for a node or edge attribute

Numeric attributes get a range input; all other attributes get a set of
checkboxes (one per level) with "Select all" / "Select none" buttons.

## Usage

``` r
make_cutoff_ui(id, x, g, what = c("node", "edge"), selected = NULL)
```

## Arguments

- id:

  id

- x:

  attribute filter

- g:

  An igraph object.

- what:

  Either `"node"` or `"edge"`.

- selected:

  previous selected values

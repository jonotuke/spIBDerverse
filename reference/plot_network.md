# Plot a network

Plot a network

## Usage

``` r
plot_network(
  g,
  seed = 2026,
  connected = "Show",
  layout = "nicely",
  lat = "none",
  long = "none",
  edge = "none",
  edge_legend = TRUE,
  edge_trans = "identity",
  edge_label = NULL,
  label = "none",
  label_filter = "none",
  label_size = 4,
  label_inc = "",
  label_exc = "",
  label_col = "black",
  fill = "none",
  fill_label = NULL,
  shape = "none",
  shape_label = NULL,
  size = "none",
  outline_col = "none",
  outline_label = NULL,
  alpha = "none",
  alpha_label = NULL,
  node_size = 5,
  fill_pal = "default",
  col_pal = "default",
  outline_width = 1,
  legend_size = 4,
  legend_stroke = 1,
  convert_nas = TRUE
)
```

## Arguments

- g:

  An igraph network.

- seed:

  Random seed used for the node layout.

- connected:

  How to treat unconnected (isolated) nodes: "Show" leaves them as they
  are, "Hide" removes them from the plot, and "Grey out" draws them (and
  their labels) with an alpha of 0.1. The layout is always computed on
  the full network, so the other nodes don't move.

- layout:

  node layout

- lat, long:

  Vertex attributes holding latitude and longitude. Supply both to use a
  geographic layout, or neither for a force-directed layout.

- edge:

  Edge attribute mapped to line width (numeric) or line type (anything
  else).

- edge_legend:

  Show the edge legend?

- edge_trans:

  Transformation applied to a numeric `edge` mapping.

- edge_label:

  Title for the edge legend. Defaults to the name of the `edge`
  attribute.

- label:

  Vertex attribute used for node labels.

- label_filter:

  Vertex attribute that `label_inc` / `label_exc` are matched against.
  Defaults to `label`.

- label_size:

  Label text size.

- label_inc:

  Regular expression; only labels matching it are shown.

- label_exc:

  Regular expression; labels matching it are hidden.

- label_col:

  Colour of label

- fill:

  Vertex attribute mapped to node fill.

- fill_label, outline_label, shape_label, alpha_label:

  Titles for the fill, outline colour, shape and alpha legends. Each
  defaults to the name of the attribute it maps. When several of these
  aesthetics map the same attribute they share one title, so their
  legends stay merged; if more than one of their labels is set, the
  first in the order fill, outline, shape, alpha wins.

- shape:

  Vertex attribute mapped to node shape.

- size:

  Vertex attribute mapped to node size.

- outline_col:

  Vertex attribute mapped to node outline colour

- alpha:

  Vertex attribute to use for mapping for node alpha

- node_size:

  Base node size.

- fill_pal:

  Fill palette name.

- col_pal:

  Colour palette name.

- outline_width:

  width of node outline

- legend_size:

  Fixed size of the node symbols in the legend keys, regardless of
  `node_size` or any `size` mapping.

- legend_stroke:

  Fixed outline width of the node symbols in the legend keys, regardless
  of `outline_width`.

- convert_nas:

  boolean to convert missing nodes attr from NA to unknown

## Value

A ggplot object.

## Examples

``` r
plot_network(example_network)
```

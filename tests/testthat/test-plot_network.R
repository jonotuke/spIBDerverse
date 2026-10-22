# Tests for plot_network() and its helpers (is_none(), check_columns()).
#
# Place this file in tests/testthat/. It assumes the package is loaded (e.g.
# via devtools::load_all() or devtools::test()), so internal helpers such as
# fill_discrete(), colour_continuous() and convert_pipe() are available.

# TEST FIXTURES ----

# A small undirected network with:
#   * a 4-cycle A-B-C-D (connected nodes)
#   * E: a node with no edges (isolated)
#   * F: a node whose only edge is a self-loop (still counts as isolated)
make_test_network <- function() {
  edges <- data.frame(
    from = c("A", "B", "C", "D", "F"),
    to = c("B", "C", "D", "A", "F"),
    weight = c(1, 2, 3, 4, 5),
    type = c("road", "rail", "road", "rail", "road")
  )
  vertices <- data.frame(
    name = c("A", "B", "C", "D", "E", "F"),
    group = c("north", "north", "south", "south", "east", "east"),
    category = c("keep", "keep", "drop", "keep", "drop", "keep"),
    value = c(1, 2, 3, 4, 5, 6),
    opacity = c(0.2, 0.4, 0.6, 0.8, 1, 1),
    lat = c(-34.9, -35.0, -34.8, -34.7, -35.1, -34.6),
    long = c(138.6, 138.7, 138.5, 138.8, 138.4, 138.9)
  )
  igraph::graph_from_data_frame(edges, vertices = vertices, directed = FALSE)
}

# Node rows in a ggnetwork data frame are the ones with no edge attributes.
node_rows <- function(df) df[is.na(df$weight), , drop = FALSE]

# Find the first layer whose geom has the given class.
find_layer <- function(p, geom_class) {
  for (layer in p$layers) {
    if (inherits(layer$geom, geom_class)) return(layer)
  }
  NULL
}

# Mapped aesthetic names (as strings) for a layer.
mapped_aes <- function(layer) names(layer$mapping)

# The node layer is the last GeomPoint layer (the underlay comes first).
node_layer <- function(p) {
  points <- Filter(function(l) inherits(l$geom, "GeomPoint"), p$layers)
  points[[length(points)]]
}

underlay_layer <- function(p) {
  points <- Filter(function(l) inherits(l$geom, "GeomPoint"), p$layers)
  points[[1]]
}

label_layer <- function(p) find_layer(p, "GeomText")

# Evaluate the label column the label layer will actually draw.
built_labels <- function(p) {
  layer_idx <- which(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomText"),
    logical(1)
  ))
  ggplot2::layer_data(p, layer_idx)$label
}

# HELPERS: is_none() ----

test_that("is_none() recognises NULL, empty string and 'none'", {
  expect_true(is_none(NULL))
  expect_true(is_none(""))
  expect_true(is_none("none"))
})

test_that("is_none() is FALSE for real attribute names", {
  expect_false(is_none("group"))
  expect_false(is_none("None"))
  expect_false(is_none(" "))
})

# HELPERS: check_columns() ----

test_that("check_columns() passes silently when all columns exist", {
  df <- data.frame(a = 1, b = 2)
  expect_silent(check_columns(df, c("a", "b")))
})

test_that("check_columns() ignores 'none' and empty placeholders", {
  df <- data.frame(a = 1)
  expect_silent(check_columns(df, c("a", "none", "")))
})

test_that("check_columns() errors listing every missing column", {
  df <- data.frame(a = 1)
  expect_error(
    check_columns(df, c("a", "foo", "bar")),
    "Attribute\\(s\\) not found in network: foo, bar"
  )
})

# BASIC OUTPUT ----

test_that("plot_network() returns a ggplot that builds without error", {
  p <- plot_network(make_test_network())
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("default node layer uses fixed white fill, black outline, shape 21", {
  p <- plot_network(make_test_network(), node_size = 7, outline_width = 2)
  params <- node_layer(p)$aes_params
  expect_equal(params$fill, "white")
  expect_equal(params$colour, "black")
  expect_equal(params$shape, 21)
  expect_equal(params$size, 7)
  expect_equal(params$stroke, 2)
})

test_that("the plot data carries vertex and edge attributes", {
  p <- plot_network(make_test_network())
  expect_true(all(
    c(
      "x",
      "y",
      "xend",
      "yend",
      "name",
      "group",
      "weight",
      ".isolated",
      ".alpha"
    ) %in%
      names(p$data)
  ))
})

# SEED / LAYOUT ----

test_that("the same seed gives the same layout", {
  g <- make_test_network()
  p1 <- plot_network(g, seed = 1)
  p2 <- plot_network(g, seed = 1)
  expect_equal(p1$data[, c("x", "y")], p2$data[, c("x", "y")])
})

test_that("different seeds give different layouts", {
  g <- make_test_network()
  p1 <- plot_network(g, seed = 1)
  p2 <- plot_network(g, seed = 2)
  expect_false(isTRUE(all.equal(p1$data$x, p2$data$x)))
})

# CONNECTED ----

test_that("isolated nodes (incl. self-loop-only nodes) are flagged", {
  p <- plot_network(make_test_network())
  nodes <- node_rows(p$data)
  isolated <- setNames(nodes$.isolated, nodes$name)
  expect_equal(
    isolated[c("A", "B", "C", "D", "E", "F")],
    c(A = FALSE, B = FALSE, C = FALSE, D = FALSE, E = TRUE, F = TRUE)
  )
})

test_that("invalid `connected` values are rejected", {
  expect_error(plot_network(make_test_network(), connected = "Invisible"))
})

test_that("`connected` accepts partial matches", {
  p <- plot_network(make_test_network(), connected = "Hi")
  expect_false(any(p$data$.isolated))
})

test_that("connected = 'Show' keeps every node fully opaque", {
  p <- plot_network(make_test_network(), connected = "Show")
  expect_setequal(node_rows(p$data)$name, c("A", "B", "C", "D", "E", "F"))
  expect_true(all(p$data$.alpha == 1))
})

test_that("connected = 'Hide' removes isolated nodes from the data", {
  p <- plot_network(make_test_network(), connected = "Hide")
  expect_setequal(unique(p$data$name), c("A", "B", "C", "D"))
  expect_false(any(p$data$.isolated))
})

test_that("connected = 'Hide' does not move the remaining nodes", {
  g <- make_test_network()
  shown <- node_rows(plot_network(g, connected = "Show")$data)
  hidden <- node_rows(plot_network(g, connected = "Hide")$data)
  shown <- shown[shown$name %in% hidden$name, ]
  shown <- shown[order(shown$name), c("name", "x", "y")]
  hidden <- hidden[order(hidden$name), c("name", "x", "y")]
  rownames(shown) <- rownames(hidden) <- NULL
  expect_equal(hidden, shown)
})

test_that("connected = 'Hide' errors when every node is isolated", {
  g <- igraph::make_empty_graph(n = 3, directed = FALSE)
  expect_error(
    plot_network(g, connected = "Hide"),
    "No connected nodes left to plot after hiding."
  )
})

test_that("connected = 'Grey out' fades only isolated nodes", {
  p <- plot_network(make_test_network(), connected = "Grey out")
  expect_true(all(p$data$.alpha[p$data$.isolated] == 0.1))
  expect_true(all(p$data$.alpha[!p$data$.isolated] == 1))
})

test_that("node alpha maps to .alpha with an identity scale by default", {
  p <- plot_network(make_test_network(), connected = "Grey out")
  expect_true("alpha" %in% mapped_aes(node_layer(p)))
  expect_equal(rlang::as_label(node_layer(p)$mapping$alpha), ".alpha")
  expect_s3_class(p$scales$get_scales("alpha"), "ScaleContinuousIdentity")
})

# GEOGRAPHIC LAYOUT ----

test_that("lat/long place nodes at their coordinates with coord_quickmap", {
  p <- plot_network(make_test_network(), lat = "lat", long = "long")
  nodes <- node_rows(p$data)
  nodes <- nodes[order(nodes$name), ]
  expect_equal(nodes$x, c(138.6, 138.7, 138.5, 138.8, 138.4, 138.9))
  expect_equal(nodes$y, c(-34.9, -35.0, -34.8, -34.7, -35.1, -34.6))
  expect_s3_class(p$coordinates, "CoordQuickmap")
})

test_that("non-geographic layouts use the default cartesian coordinates", {
  p <- plot_network(make_test_network())
  expect_false(inherits(p$coordinates, "CoordQuickmap"))
})

test_that("supplying only one of lat/long errors", {
  g <- make_test_network()
  msg <- "Supply both `lat` and `long`, or neither."
  expect_error(plot_network(g, lat = "lat"), msg)
  expect_error(plot_network(g, long = "long"), msg)
})

test_that("missing or non-numeric coordinates error", {
  msg <- "`lat`/`long` contain missing or non-numeric values."

  g_na <- make_test_network()
  igraph::V(g_na)$lat[2] <- NA
  expect_error(plot_network(g_na, lat = "lat", long = "long"), msg)

  g_chr <- make_test_network()
  igraph::V(g_chr)$lat <- c("a", "b", "c", "d", "e", "f")
  expect_error(
    suppressWarnings(plot_network(g_chr, lat = "lat", long = "long")),
    msg
  )
})

test_that("numeric coordinates stored as character are accepted", {
  g <- make_test_network()
  igraph::V(g)$lat <- as.character(igraph::V(g)$lat)
  expect_no_error(plot_network(g, lat = "lat", long = "long"))
})

# ATTRIBUTE CHECKS ----

test_that("unknown attribute names give an informative error", {
  g <- make_test_network()
  msg <- "Attribute\\(s\\) not found in network: nope"
  expect_error(plot_network(g, fill = "nope"), msg)
  expect_error(plot_network(g, shape = "nope"), msg)
  expect_error(plot_network(g, size = "nope"), msg)
  expect_error(plot_network(g, outline_col = "nope"), msg)
  expect_error(plot_network(g, edge = "nope"), msg)
  expect_error(plot_network(g, label = "nope"), msg)
  expect_error(plot_network(g, label = "name", label_filter = "nope"), msg)
})

test_that("all missing attributes are reported together", {
  expect_error(
    plot_network(make_test_network(), fill = "foo", shape = "bar"),
    "foo, bar"
  )
})

# EDGES ----

test_that("no edge mapping draws plain edges without width/linetype", {
  p <- plot_network(make_test_network())
  edges <- find_layer(p, "GeomSegment")
  expect_false(any(c("linewidth", "linetype") %in% mapped_aes(edges)))
})

test_that("a numeric edge attribute maps to linewidth with a 0.5-2 range", {
  p <- plot_network(make_test_network(), edge = "weight")
  edges <- find_layer(p, "GeomSegment")
  expect_true("linewidth" %in% mapped_aes(edges))
  expect_s3_class(p$scales$get_scales("linewidth"), "ScaleContinuous")
  built <- ggplot2::layer_data(p, 1)
  expect_equal(range(built$linewidth, na.rm = TRUE), c(0.5, 2))
})

test_that("edge_trans is passed to the linewidth scale", {
  p <- plot_network(make_test_network(), edge = "weight", edge_trans = "log10")
  scale <- p$scales$get_scales("linewidth")
  expect_equal(scale$trans$name, "log-10")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("a non-numeric edge attribute maps to linetype", {
  p <- plot_network(make_test_network(), edge = "type")
  edges <- find_layer(p, "GeomSegment")
  expect_true("linetype" %in% mapped_aes(edges))
  expect_false("linewidth" %in% mapped_aes(edges))
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("edge_legend controls the edge layer's legend", {
  g <- make_test_network()
  on <- find_layer(
    plot_network(g, edge = "type", edge_legend = TRUE),
    "GeomSegment"
  )
  off <- find_layer(
    plot_network(g, edge = "type", edge_legend = FALSE),
    "GeomSegment"
  )
  expect_true(on$show.legend)
  expect_false(off$show.legend)
})

# NODES: fill ----

test_that("a discrete fill attribute gets a discrete fill scale", {
  p <- plot_network(make_test_network(), fill = "group")
  expect_equal(rlang::as_label(node_layer(p)$mapping$fill), "group")
  expect_null(node_layer(p)$aes_params$fill)
  expect_s3_class(p$scales$get_scales("fill"), "ScaleDiscrete")
})

test_that("a numeric fill attribute gets a continuous fill scale", {
  p <- plot_network(make_test_network(), fill = "value")
  expect_s3_class(p$scales$get_scales("fill"), "ScaleContinuous")
  expect_no_error(ggplot2::ggplot_build(p))
})

# NODES: outline colour ----

test_that("a discrete outline_col attribute gets a discrete colour scale", {
  p <- plot_network(make_test_network(), outline_col = "group")
  expect_equal(rlang::as_label(node_layer(p)$mapping$colour), "group")
  expect_null(node_layer(p)$aes_params$colour)
  expect_s3_class(p$scales$get_scales("colour"), "ScaleDiscrete")
})

test_that("a numeric outline_col attribute gets a continuous colour scale", {
  p <- plot_network(make_test_network(), outline_col = "value")
  expect_s3_class(p$scales$get_scales("colour"), "ScaleContinuous")
  expect_no_error(ggplot2::ggplot_build(p))
})

# NODES: shape ----

test_that("shape mapping uses fillable shapes 21-25, one per level", {
  p <- plot_network(make_test_network(), shape = "group")
  expect_equal(rlang::as_label(node_layer(p)$mapping$shape), "group")
  built <- ggplot2::layer_data(p, length(p$layers))
  expect_true(all(built$shape %in% 21:25))
  expect_length(unique(built$shape), 3)
})

test_that("shape values recycle when there are more than five levels", {
  g <- make_test_network()
  igraph::V(g)$many <- letters[1:6]
  p <- plot_network(g, shape = "many")
  built <- ggplot2::layer_data(p, length(p$layers))
  expect_true(all(built$shape %in% 21:25))
})

# NODES: size ----

test_that("size mapping uses a range of node_size/2 to node_size*2", {
  p <- plot_network(make_test_network(), size = "value", node_size = 4)
  expect_equal(rlang::as_label(node_layer(p)$mapping$size), "value")
  expect_null(node_layer(p)$aes_params$size)
  built <- ggplot2::layer_data(p, length(p$layers))
  expect_equal(range(built$size), c(2, 8))
})

# NODES: alpha ----

test_that("a user alpha attribute replaces the .alpha mapping", {
  p <- plot_network(make_test_network(), alpha = "opacity")
  expect_equal(rlang::as_label(node_layer(p)$mapping$alpha), "opacity")
  expect_no_error(ggplot2::ggplot_build(p))
})

# UNDERLAY ----

test_that("the underlay is solid white with no legend", {
  p <- plot_network(make_test_network(), fill = "group", outline_col = "group")
  underlay <- underlay_layer(p)
  expect_equal(underlay$aes_params$fill, "white")
  expect_equal(underlay$aes_params$colour, "white")
  expect_equal(underlay$aes_params$alpha, 1)
  expect_false(underlay$show.legend)
  expect_false(any(c("fill", "colour", "alpha") %in% mapped_aes(underlay)))
})

test_that("the underlay copies fixed size, shape and stroke from the nodes", {
  p <- plot_network(make_test_network(), node_size = 6, outline_width = 3)
  underlay <- underlay_layer(p)
  expect_equal(underlay$aes_params$size, 6)
  expect_equal(underlay$aes_params$shape, 21)
  expect_equal(underlay$aes_params$stroke, 3)
})

test_that("the underlay copies mapped size and shape from the nodes", {
  p <- plot_network(make_test_network(), size = "value", shape = "group")
  underlay <- underlay_layer(p)
  expect_equal(rlang::as_label(underlay$mapping$size), "value")
  expect_equal(rlang::as_label(underlay$mapping$shape), "group")
})

# LABELS ----

test_that("label adds a text layer with the requested colour and size", {
  p <- plot_network(
    make_test_network(),
    label = "name",
    label_col = "red",
    label_size = 6
  )
  lbl <- label_layer(p)
  expect_false(is.null(lbl))
  expect_equal(lbl$aes_params$colour, "red")
  expect_equal(lbl$aes_params$size, 6)
  expect_true(all(c("label", "alpha") %in% mapped_aes(lbl)))
})

test_that("all labels are shown when no filters are given", {
  p <- plot_network(make_test_network(), label = "name")
  expect_setequal(
    stats::na.omit(built_labels(p)),
    c("A", "B", "C", "D", "E", "F")
  )
})

test_that("label_inc keeps only matching labels", {
  p <- plot_network(make_test_network(), label = "name", label_inc = "^[AB]$")
  expect_setequal(stats::na.omit(built_labels(p)), c("A", "B"))
})

test_that("label_exc hides matching labels", {
  p <- plot_network(make_test_network(), label = "name", label_exc = "^[AB]$")
  expect_setequal(stats::na.omit(built_labels(p)), c("C", "D", "E", "F"))
})

test_that("label_inc and label_exc combine", {
  p <- plot_network(
    make_test_network(),
    label = "name",
    label_inc = "^[ABC]$",
    label_exc = "^B$"
  )
  expect_setequal(stats::na.omit(built_labels(p)), c("A", "C"))
})

test_that("label_filter matches against a different attribute", {
  p <- plot_network(
    make_test_network(),
    label = "name",
    label_filter = "category",
    label_inc = "keep"
  )
  expect_setequal(stats::na.omit(built_labels(p)), c("A", "B", "D", "F"))
})

test_that("a label_inc matching nothing hides every label without error", {
  p <- plot_network(make_test_network(), label = "name", label_inc = "zzz")
  expect_true(all(is.na(p$data$.label)))
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("labels of greyed-out nodes inherit the faded alpha", {
  p <- plot_network(make_test_network(), label = "name", connected = "Grey out")
  idx <- which(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomText"),
    logical(1)
  ))
  built <- ggplot2::layer_data(p, idx)
  expect_true(all(built$alpha[built$label %in% c("E", "F")] == 0.1))
  expect_true(all(built$alpha[built$label %in% c("A", "B", "C", "D")] == 1))
})

test_that("labels work alongside connected = 'Hide'", {
  p <- plot_network(make_test_network(), label = "name", connected = "Hide")
  expect_setequal(stats::na.omit(built_labels(p)), c("A", "B", "C", "D"))
})

# LEGENDS ----

test_that("the size legend is always suppressed", {
  p <- plot_network(make_test_network(), size = "value")
  expect_equal(p$guides$guides$size, "none")
})

test_that("discrete fill, colour and shape legends get fixed-size keys", {
  p <- plot_network(
    make_test_network(),
    fill = "group",
    outline_col = "category",
    shape = "group",
    legend_size = 3,
    legend_stroke = 0.5
  )
  for (aes_name in c("fill", "colour", "shape")) {
    guide <- p$guides$guides[[aes_name]]
    expect_s3_class(guide, "GuideLegend")
    expect_equal(guide$params$override.aes$size, 3)
    expect_equal(guide$params$override.aes$stroke, 0.5)
    expect_equal(guide$params$override.aes$alpha, 1)
  }
})

test_that("continuous fill and colour keep their default colourbar", {
  p <- plot_network(make_test_network(), fill = "value", outline_col = "value")
  expect_null(p$guides$guides$fill)
  expect_null(p$guides$guides$colour)
})

test_that("edge lines are removed from node legend keys when edges have a legend", {
  p <- plot_network(make_test_network(), edge = "type", fill = "group")
  expect_true(is.na(p$guides$guides$fill$params$override.aes$linetype))
})

test_that("linetype override is not added when there is no edge legend", {
  g <- make_test_network()
  p_none <- plot_network(g, fill = "group")
  p_off <- plot_network(g, edge = "type", edge_legend = FALSE, fill = "group")
  expect_null(p_none$guides$guides$fill$params$override.aes$linetype)
  expect_null(p_off$guides$guides$fill$params$override.aes$linetype)
})

# FULL COMBINATION ----

test_that("every option can be used together", {
  p <- plot_network(
    make_test_network(),
    seed = 42,
    connected = "Grey out",
    lat = "lat",
    long = "long",
    edge = "weight",
    edge_trans = "sqrt",
    label = "name",
    label_filter = "category",
    label_inc = "keep",
    label_exc = "^nothing$",
    fill = "group",
    shape = "category",
    size = "value",
    outline_col = "value",
    node_size = 3
  )
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

# Helper: a small Ringbauer-style tibble with two groups (A, B).
# The A-B and B-A edges are duplicates that plot_homophily() should collapse.
make_rm <- function() {
  tibble::tribble(
    ~grp1 , ~grp2 , ~density , ~adj_pv ,
    "A"   , "A"   , 0.40     , 0.01    ,
    "A"   , "B"   , 0.10     , 0.20    ,
    "B"   , "A"   , 0.20     , 0.40    ,
    "B"   , "B"   , 0.30     , 0.03
  ) |>
    dplyr::mutate(overall_density = 0.25)
}

# Helper: the data the plot was built from.
plot_data <- function(...) {
  plot_homophily(...)$data
}

# Helper: the single between-group row (labels may be A-B or B-A).
between_row <- function(edges) {
  edges[edges$grp1 != edges$grp2, ]
}

test_that("returns a ggplot object", {
  expect_s3_class(plot_homophily(make_rm()), "ggplot")
})

test_that("builds without warnings in every mode", {
  for (show in c(FALSE, TRUE)) {
    for (filter in c(FALSE, TRUE)) {
      p <- plot_homophily(make_rm(), show_sign = show, filter_sign = filter)
      expect_no_warning(ggplot2::ggplot_build(p))
    }
  }
})

test_that("missing densities are dropped", {
  rm <- make_rm() |>
    dplyr::bind_rows(
      tibble::tibble(
        grp1 = c("C", "D"),
        grp2 = c("C", "D"),
        density = c(NaN, NA),
        adj_pv = 0.5,
        overall_density = 0.25
      )
    )

  edges <- plot_data(rm)

  expect_false(any(c("C", "D") %in% c(edges$grp1, edges$grp2)))
  expect_false(anyNA(edges$density))
})

test_that("duplicate edges are collapsed and averaged", {
  edges <- plot_data(make_rm())
  between <- between_row(edges)

  expect_equal(nrow(edges), 3)
  expect_equal(nrow(between), 1)
  expect_equal(between$density, mean(c(0.10, 0.20)))
  expect_equal(between$adj_pv, mean(c(0.20, 0.40)))
})

test_that("edge names combine both groups", {
  edges <- plot_data(make_rm())

  expect_setequal(
    as.character(edges$name[edges$grp1 == edges$grp2]),
    c("A-A", "B-B")
  )
  expect_true(as.character(between_row(edges)$name) %in% c("A-B", "B-A"))
})

test_that("edges are ordered by density on the x axis", {
  edges <- plot_data(make_rm())

  expected_order <- as.character(edges$name[order(edges$density)])
  expect_s3_class(edges$name, "factor")
  expect_equal(levels(edges$name), expected_order)
})

test_that("type is within/between by default", {
  edges <- plot_data(make_rm())

  expect_setequal(unique(edges$type), c("within", "between"))
  expect_equal(edges$type[edges$grp1 == edges$grp2], c("within", "within"))
  expect_equal(between_row(edges)$type, "between")
})

test_that("show_sign colours by significance", {
  edges <- plot_data(make_rm(), show_sign = TRUE)

  expect_setequal(unique(edges$type), c("significant", "not significant"))
  expect_equal(
    edges$type,
    ifelse(edges$adj_pv <= 0.05, "significant", "not significant")
  )
})

test_that("sig_level changes the significance threshold", {
  # Between edge has mean adj_pv 0.3, so a 0.5 threshold makes all significant
  edges <- plot_data(make_rm(), show_sign = TRUE, sig_level = 0.5)
  expect_true(all(edges$type == "significant"))

  edges <- plot_data(make_rm(), show_sign = TRUE, sig_level = 0.001)
  expect_true(all(edges$type == "not significant"))
})

test_that("nothing is faded unless filter_sign = TRUE", {
  edges <- plot_data(make_rm())
  expect_false(any(edges$faded))
})

test_that("filter_sign fades only non-significant edges", {
  edges <- plot_data(make_rm(), filter_sign = TRUE)

  expect_equal(edges$faded, edges$adj_pv > 0.05)
  expect_true(any(edges$faded))
  expect_false(all(edges$faded))
})

test_that("faded points are drawn with lower alpha", {
  p <- plot_homophily(make_rm(), filter_sign = TRUE)
  built <- ggplot2::ggplot_build(p)

  point_layer <- which(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomPoint"),
    logical(1)
  ))
  alphas <- built$data[[point_layer]]$alpha

  expect_setequal(unique(alphas), c(1, 0.2))
})

test_that("reference line sits at the overall density", {
  p <- plot_homophily(make_rm())
  built <- ggplot2::ggplot_build(p)

  hline_layer <- which(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomHline"),
    logical(1)
  ))

  expect_length(hline_layer, 1)
  expect_equal(built$data[[hline_layer]]$yintercept, 0.25)
})

test_that("axis labels are set", {
  p <- plot_homophily(make_rm())

  expect_equal(p$labels$x, "Edge")
  expect_equal(p$labels$y, "Connectivity")
})

test_that("works end to end with get_ringbauer_measures()", {
  rm <- get_ringbauer_measures(example_network, "site")

  expect_s3_class(plot_homophily(rm), "ggplot")
  expect_s3_class(
    plot_homophily(rm, show_sign = TRUE, filter_sign = TRUE),
    "ggplot"
  )
})

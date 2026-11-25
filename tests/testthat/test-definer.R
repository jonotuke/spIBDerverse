test_that("definer values", {
  igraph::vcount(example_network)
  expect_equal(
    definer(example_network) |> igraph::vcount(),
    40
  )
  expect_equal(
    definer(example_network) |> igraph::ecount(),
    102
  )
  expect_equal(
    definer(
      example_network,
      edge_filters = list(
        wij = c(0.5, NA),
        edge_type = "A"
      )
    ) |>
      igraph::vcount(),
    40
  )
  expect_equal(
    definer(
      example_network,
      edge_filters = list(
        wij = c(0.5, NA),
        edge_type = "A"
      )
    ) |>
      igraph::ecount(),
    19
  )
})

test_that("in_cutoff args", {
  expect_error(in_cutoff(1:10, 1))
  expect_error(in_cutoff(1:10, c("1", "2")))
  expect_error(in_cutoff(c("1", "2"), 1))
})

test_that("in_cutoff values", {
  expect_equal(
    in_cutoff(1:4, c(1, 2)),
    c(TRUE, TRUE, FALSE, FALSE)
  )
  expect_equal(
    in_cutoff(1:4, c(NA, 2)),
    c(TRUE, TRUE, FALSE, FALSE)
  )
  expect_equal(
    in_cutoff(1:4, c(2, NA)),
    c(FALSE, TRUE, TRUE, TRUE)
  )
  expect_equal(
    in_cutoff(LETTERS[1:4], c("A")),
    c(TRUE, FALSE, FALSE, FALSE)
  )
  expect_equal(
    in_cutoff(LETTERS[1:4], c("A", "D")),
    c(TRUE, FALSE, FALSE, TRUE)
  )
})

test_that("keep_edges args", {
  expect_error(
    keep_edges(example_network)
  )
  expect_error(
    keep_edges(
      example_network,
      filters = list(
        wij = c(NA, 10),
        wij = c(NA, 10)
      )
    )
  )
  expect_error(
    keep_edges(
      example_network,
      filters = list(
        site = "A"
      )
    )
  )
})

test_that("keep_edges values", {
  expect_equal(
    keep_edges(
      example_network,
      filters = list(
        wij = c(0.5, NA),
        edge_type = "A"
      )
    ),
    # fmt: skip
    c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 
    TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, 
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, 
    FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, 
    FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, 
    TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, 
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, 
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 
    FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 
    FALSE)
  )
})

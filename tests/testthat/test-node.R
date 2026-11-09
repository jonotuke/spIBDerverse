test_that("get_network_summary args", {
  expect_error(get_network_summary(list()))
})

test_that("get_network_summary values", {
  measures <- get_network_summary(example_network) |> dplyr::pull(measure)
  value <- get_network_summary(example_network) |> dplyr::pull(value)
  expect_equal(
    measures,
    c(
      "Number of nodes",
      "Number of edges",
      "Number of unconnected nodes",
      "Number of nodes missing: genetic_sex",
      "Number of nodes missing: site",
      "Number of nodes missing: lat",
      "Number of nodes missing: long"
    )
  )
  expect_equal(value, c(40, 134, 0, 0, 0, 0, 0))
})

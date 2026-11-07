test_that("plot centrality", {
  expect_error(plot_centrality(example_network, "DEGREE"))
})

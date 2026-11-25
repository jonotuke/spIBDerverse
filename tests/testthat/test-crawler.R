test_that("crawler args", {
  expect_error(crawler(list()))
  expect_error(crawler(example_network, nodes = c("1", "2")))
})

test_that("crawler values", {
  g <- crawler(example_network, nodes = c(1, 2))
  expect_true(".crawl" %in% igraph::vertex_attr_names(g))
})

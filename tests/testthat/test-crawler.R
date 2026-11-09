test_that("label_crawl args", {
  expect_error(label_crawl(list()))
  expect_error(label_crawl(example_network, nodes = c("1", "2")))
  expect_error(label_crawl(example_network, nodes = c(1, 2), k = 1.1))
})

test_that("label_crawl values", {
  g <- label_crawl(example_network, nodes = c(1, 2))
  expect_true(".crawl" %in% igraph::vertex_attr_names(g))
})

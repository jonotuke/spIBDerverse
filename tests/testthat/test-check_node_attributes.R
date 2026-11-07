test_that("Get errors", {
  expect_error(
    check_node_attributes(example_network, "bob")
  )
  expect_null(
    check_node_attributes(example_network, "site")
  )
})

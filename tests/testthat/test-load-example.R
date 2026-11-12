test_that("load-example", {
  expect_error(load_example("bob"))
  expect_equal(load_example("example_network_2"), example_network_2)
})

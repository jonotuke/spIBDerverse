test_that("get example works", {
  expect_equal(load_example(), example_network)
  expect_message(load_example("example_network_4"))
})

test_that("get example works", {
  expect_equal(get_example(), example_network)
  expect_message(get_example("example_network_4"))
})

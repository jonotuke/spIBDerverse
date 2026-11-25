examples <- c(
  "example_network",
  stringr::str_c("example_network_", 2:7)
)
examples <- purrr::set_names(examples) |>
  purrr::map(\(x) get(x, "package:spIBDerverse"))

vars <- c(".crawl", ".degree", ".louvain")
test_that("example networks were found", {
  expect_gt(length(examples), 0)
})

test_that("crawl, central, and clustering", {
  examples |>
    purrr::iwalk(
      \(x, n) {
        # print(n)
        expect_all_true(
          vars %in% igraph::vertex_attr_names(x)
        )
      }
    )
})

test_that("sort_label", {
  expect_equal(
    sort_label("A", "B"),
    "A-B"
  )
  expect_equal(
    sort_label("B", "A"),
    "A-B"
  )
  expect_equal(
    sort_label("A", "A"),
    "A-A"
  )
})

test_that("label_grp_duplicates", {
  df <- tibble::tibble(
    grp1 = c("A", "A", "B"),
    grp2 = c("A", "B", "A")
  ) |>
    dplyr::mutate(
      value = 1:3
    )
  expect_equal(
    label_grp_duplicates(df, grp1, grp2) |>
      dplyr::pull(.grp_label),
    c("A-A", "A-B", "A-B")
  )
})

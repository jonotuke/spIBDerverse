ibd_file <- fs::path_package(
  "extdata",
  "example-ibd-data.tsv",
  package = "spIBDerverse"
)
meta_file <- fs::path_package(
  "extdata",
  "example-meta-data.tsv",
  package = "spIBDerverse"
)
broken_ibd_1 <- fs::path_package(
  "extdata",
  "ibd-no-iid1-iid2.tsv",
  package = "spIBDerverse"
)
broken_ibd_2 <- fs::path_package(
  "extdata",
  "ibd-no-iid1.tsv",
  package = "spIBDerverse"
)
broken_ibd_3 <- fs::path_package(
  "extdata",
  "ibd-no-iid2.tsv",
  package = "spIBDerverse"
)
broken_meta <- fs::path_package(
  "extdata",
  "meta-no-iid.tsv",
  package = "spIBDerverse"
)
test_that("IBD upload works", {
  expect_message(
    create_ibd_network(
      broken_ibd_1,
      meta_file
    )
  )
  expect_message(
    create_ibd_network(
      broken_ibd_2,
      meta_file
    )
  )
  expect_message(
    create_ibd_network(
      broken_ibd_3,
      meta_file
    )
  )
})
test_that("Meta upload works", {
  expect_message(
    create_ibd_network(
      ibd_file,
      broken_meta
    )
  )
})

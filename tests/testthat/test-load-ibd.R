good_meta <- fs::path_package(
  package = "spIBDerverse",
  "extdata/example-meta-data.tsv"
)
good_ibd <- fs::path_package(
  package = "spIBDerverse",
  "extdata/example-ibd-data.tsv"
)
no_iids <- fs::path_package(
  package = "spIBDerverse",
  "extdata/ibd-no-iid1-iid2.tsv"
)
no_iid <- fs::path_package(
  package = "spIBDerverse",
  "extdata/meta-no-iid.tsv"
)
no_frac <- fs::path_package(
  package = "spIBDerverse",
  "extdata/meta-no-frac-gp.tsv"
)
ibd_igraph <- fs::path_package(
  package = "spIBDerverse",
  "extdata/ibd-igraph-fail.tsv"
)
meta_igraph <- fs::path_package(
  package = "spIBDerverse",
  "extdata/meta-igraph-fail.tsv"
)
meta_missing_nodes <- fs::path_package(
  package = "spIBDerverse",
  "extdata/meta-missing-nodes.tsv"
)
test_that("load_ibd args", {
  expect_error(load_ibd(ibd_co = c("A")))
  expect_error(load_ibd(ibd_co = 1:3))
  expect_error(load_ibd(ibd_file = no_iids))
  expect_error(load_ibd(meta_file = "extdata/example-meta-data.bob"))
  expect_message(load_ibd(ibd_file = good_ibd, meta_file = no_iid))
  expect_error(load_ibd(ibd_file = good_ibd, meta_file = no_frac))
  expect_error(load_ibd(ibd_file = ibd_igraph, meta_file = meta_igraph))
})

test_that("load_ibd values", {
  g <- load_ibd(ibd_file = good_ibd, meta_file = good_meta)
  expect_equal(igraph::vcount(g), 328)
  expect_equal(igraph::ecount(g), 1712)
  expect_true(all(c(".degree", ".louvain") %in% igraph::vertex_attr_names(g)))
  g <- load_ibd(ibd_file = good_ibd, meta_file = meta_missing_nodes)
  expect_equal(igraph::vcount(g), 10)
})

test_that("read_file", {
  expect_error(read_file("extdata/example-ibd-data.bob"))
})

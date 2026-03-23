pacman::p_load(conflicted, tidyverse, targets)
ibd_file <- fs::path_package(
  "extdata",
  "example-ibd-data.tsv",
  package = "spIBDerverse"
)
readr::read_tsv(ibd_file) |>
  readr::write_tsv("dev/test-data/ibd-good.tsv")
readr::read_tsv(ibd_file) |>
  select(-iid1) |>
  readr::write_tsv("dev/test-data/ibd-no-iid1.tsv")
readr::read_tsv(ibd_file) |>
  select(-iid2) |>
  readr::write_tsv("dev/test-data/ibd-no-iid2.tsv")
readr::read_tsv(ibd_file) |>
  select(-iid1, -iid2) |>
  readr::write_tsv("dev/test-data/ibd-no-iid1-iid2.tsv")
meta_file <- fs::path_package(
  "extdata",
  "example-meta-data.tsv",
  package = "spIBDerverse"
)
readr::read_tsv(meta_file) |>
  readr::write_tsv("dev/test-data/meta-good.tsv")
readr::read_tsv(meta_file) |>
  select(-iid) |>
  readr::write_tsv("dev/test-data/meta-no-iid.tsv")

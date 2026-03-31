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
example_network_2 <- load_ibd_network(
  ibd_file,
  meta_file,
  ibd_co = c(0, 2, 1, 0),
  frac_co = 0.49
)
igraph::V(example_network_2)$site <- stringr::str_remove_all(
  igraph::V(example_network_2)$Master_ID,
  "\\d"
)
example_network_2 |> print()
usethis::use_data(example_network_2, overwrite = TRUE)

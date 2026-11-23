igraph::as_data_frame(example_network, "edges") |>
  readr::write_tsv("inst/extdata/loader-data/loader-edges.tsv")
igraph::as_data_frame(example_network, "vertices") |>
  dplyr::relocate(name) |>
  readr::write_tsv("inst/extdata/loader-data/loader-nodes.tsv")

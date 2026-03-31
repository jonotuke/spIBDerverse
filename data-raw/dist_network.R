## code to prepare `edge_network` dataset goes here
pacman::p_load(conflicted, tidyverse, targets, igraph)
set.seed(2026)
dist_network <- sample_gnp(20, p = 0.5)
V(dist_network)$site <- sample(LETTERS[1:3], size = 20, replace = TRUE)
V(dist_network)$iid <- 1:20
E(dist_network)$dist <- runif(ecount(dist_network), 0.1, 1)
dist_network |>
  as_data_frame() |>
  rename(
    iid1 = from,
    iid2 = to
  ) |>
  write_tsv("inst/extdata/dist_network_edges.tsv")
dist_network |>
  as_data_frame(what = "vertices") |>
  write_tsv("inst/extdata/dist_network_nodes.tsv")

usethis::use_data(dist_network, overwrite = TRUE)

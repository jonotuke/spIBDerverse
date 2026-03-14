pacman::p_load(conflicted, tidyverse, targets)
centrality_network <- create_ibd_network(
  "~/Desktop/2026-03-13-ibd.tsv",
  "~/Desktop/2026-03-13-meta.tsv",
  ibd_co = c(0, 2, 1, 0)
)

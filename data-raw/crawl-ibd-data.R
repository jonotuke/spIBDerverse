pacman::p_load(conflicted, tidyverse, targets)
ibd <- readr::read_tsv(
  "inst/extdata/crawl-ibd/crawl-ibd.tsv"
)
nodes <- unique(c(ibd$iid1, ibd$iid2))
set.seed(2026)
n_seed <- 30
seed_nodes <- sample(nodes, size = n_seed)
node_df <- tibble(
  id = seed_nodes
) |>
  mutate(
    genetic_sex = sample(
      c("M", "F"),
      size = n_seed,
      replace = TRUE
    ),
    site = sample(
      LETTERS[1:3],
      size = n_seed,
      replace = TRUE
    )
  )
node_df |>
  readr::write_tsv(
    "inst/extdata/crawl-ibd/crawl-meta.tsv"
  )

pacman::p_load(conflicted, tidyverse, targets)
set.seed(2026)
n <- 20
nodes <- tibble(
  id = 1:n,
  genetic_sex = sample(
    c("M", "F"),
    size = n,
    replace = TRUE
  ),
  site = sample(
    LETTERS[1:3],
    size = n,
    replace = TRUE
  )
)
readr::write_csv(
  nodes,
  "inst/extdata/load-default-data/default-node.csv"
)
edges <- tidyr::expand_grid(
  from = nodes$id,
  to = nodes$id,
) |>
  filter(from < to) |>
  mutate(
    dist = sample(
      1:20,
      size = nrow(edges),
      replace = TRUE
    ),
    edge_type = sample(
      letters[1:4],
      size = nrow(edges),
      replace = TRUE
    )
  )
readr::write_csv(
  edges,
  "inst/extdata/load-default-data/default-edges.csv"
)

set.seed(2026)
n <- 20
nodes <- tibble::tibble(
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
edge <- tidyr::expand_grid(
  from = nodes$id,
  to = nodes$id
) |>
  dplyr::filter(from < to) |>
  dplyr::mutate(
    dist = sample(
      1:20,
      size = dplyr::n(),
      replace = TRUE
    ),
    edge_type = sample(
      letters[1:4],
      size = dplyr::n(),
      replace = TRUE
    )
  )
readr::write_csv(
  edge,
  "inst/extdata/load-default-data/default-edge.csv"
)

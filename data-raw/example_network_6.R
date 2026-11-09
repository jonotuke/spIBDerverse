## code to prepare `example_network_6` dataset goes here
example_network_6 <- example_network
example_network_6 <- igraph::set_vertex_attr(
  example_network_6,
  "Genetic Sex",
  value = sample(
    LETTERS[1:10],
    size = igraph::vcount(example_network_6),
    replace = TRUE
  )
)
usethis::use_data(example_network_6, overwrite = TRUE)

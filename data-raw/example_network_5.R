## code to prepare `example_network_5` dataset goes here
example_network_5 <- example_network_2
period <- sample(
  LETTERS[1:2],
  igraph::vcount(example_network_5),
  replace = TRUE
)
igraph::V(example_network_5)$period <- period

usethis::use_data(example_network_5, overwrite = TRUE)

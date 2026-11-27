set.seed(2026)

n <- 150
p <- 0.04
example_network_8 <- igraph::sample_gnp(n, p)
igraph::V(example_network_8)$name <- paste0("node", seq_len(n))
igraph::V(example_network_8)$site <- sample(
  c("A", "B", "C", "D"),
  n,
  replace = TRUE
)
igraph::V(example_network_8)$genetic_sex <- sample(
  c("F", "M"),
  n,
  replace = TRUE
)
igraph::V(example_network_8)$age_group <- sample(
  c("young", "mid", "old"),
  n,
  replace = TRUE
)
igraph::V(example_network_8)$household <- sample(
  paste0("H", 1:5),
  n,
  replace = TRUE
)


# options(cli.progress_show_after = 0)
# fits_big <- fit_ergms(
#   example_network_8,
#   preds = c("site", "genetic_sex", "age_group", "household"),
#   types = rep("nodematch|nodemix", 4)
# )

usethis::use_data(example_network_8, overwrite = TRUE)

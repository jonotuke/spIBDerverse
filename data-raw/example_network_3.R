## code to prepare `example_network_3` dataset goes here
library(igraph)
data(example_network)

# Add NAs to genetic sex and site

example_network_3 <- example_network
set.seed(2025)
index1 <- sample(1:40, 3)
V(example_network_3)$site[index1] <- NA
index2 <- sample(1:40, 3)
V(example_network_3)$genetic_sex[index2] <- NA
get_network_summary(example_network_3)
usethis::use_data(example_network_3, overwrite = TRUE)

## code to prepare `example_network_4` dataset goes here
library(igraph)
data(example_network)

# Add NAs to genetic sex and site

example_network_4 <- example_network
set.seed(2025)
index1 <- sample(1:40, 3)
V(example_network_4)$lat[index1] <- NA
index2 <- sample(1:40, 3)
V(example_network_4)$long[index2] <- NA
usethis::use_data(example_network_4, overwrite = TRUE)

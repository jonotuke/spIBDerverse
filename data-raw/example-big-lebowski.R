# pak::pak("schochastics/networkdata")
data(movie_103, package = "networkdata")
g <- movie_103
igraph::V(g)$name <- stringr::str_to_title(igraph::V(g)$name)
readr::write_rds(g, "inst/extdata/igraphs/big-lebowski.rds")

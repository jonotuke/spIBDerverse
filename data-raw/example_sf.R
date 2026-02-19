## code to prepare `example_sf` dataset goes here
example_sf <- convert_sf(example_network, "lat", "long", "site")
usethis::use_data(example_sf, overwrite = TRUE)

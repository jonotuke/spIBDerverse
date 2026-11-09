## code to prepare `example_spatial_ergms` dataset goes here
example_spatial_ergms <- fit_spatial_ergm(
  example_network_5,
  "Latitude",
  "Longitude",
  "period"
)

usethis::use_data(example_spatial_ergms, overwrite = TRUE)

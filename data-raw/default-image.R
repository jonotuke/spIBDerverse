## code to prepare `default-image` dataset goes here
txt_file <- fs::path_package(
  "extdata",
  "data.txt",
  package = "spIBDerverse"
)
lines <- readr::read_lines(txt_file)
n <- length(lines)
m <- stringr::str_split(lines[1], "") |> purrr::pluck(1) |> length()
default_image <- tidyr::expand_grid(row = 1:n, col = 1:m)
default_image <- default_image |> dplyr::mutate(pixel = "")
for (index in 1:nrow(default_image)) {
  line <- lines[default_image$row[index]]
  pixels <- stringr::str_split(line, "") |> purrr::pluck(1)
  pixel <- pixels[default_image$col[index]]
  default_image$pixel[index] <- pixel[1]
}
usethis::use_data(default_image, overwrite = TRUE)

copy_files <- function(folder) {
  fs::path_package(
    "extdata",
    "example-ibd-data.tsv",
    package = "spIBDerverse"
  ) |>
    fs::file_copy(
      new_path = stringr::str_glue("{folder}/example_ibd.tsv"),
      overwrite = TRUE
    )
  fs::path_package(
    "extdata",
    "example-meta-data.tsv",
    package = "spIBDerverse"
  ) |>
    fs::file_copy(
      new_path = stringr::str_glue("{folder}/example_meta.tsv"),
      overwrite = TRUE
    )
}
# pacman::p_load(conflicted, tidyverse, targets)
# copy_files("~/Desktop/") |> print()

# readr::read_tsv("~/Desktop/example_ibd.tsv")
# readr::read_tsv("~/Desktop/example_meta.tsv")

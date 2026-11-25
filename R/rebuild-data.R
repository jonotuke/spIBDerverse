#' Rebuild data
#'
#' @param path path of files for data
#' @noRd
rebuild_data <- function(path = "data-raw/") {
  files <- list.files(path, pattern = "\\.R$", full.names = TRUE)

  files |>
    purrr::walk(\(x) {
      print(x)
      source(x)
    })
}

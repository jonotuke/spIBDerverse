abbreviate_one <- function(x) {
  x |>
    stringr::str_remove_all("\\(.*\\)") |>
    stringr::str_split(" |-") |>
    purrr::pluck(1) |>
    stringr::str_sub(1, 1) |>
    stringr::str_c(collapse = "")
}
#' abbreviate labels
#'
#' @description
#' Takes first letter of each word, where a word is separated by space on hyphen
#' Also removes brackets first
#'
#' @param x vector of labels
#'
#' @returns vector of abbreviations
#'
#' @export
#' @examples
#' abbreviate(c("Jono Tuke", "Adam Ben Rohrlach", "Adelaide-University"))
abbreviate <- function(x) {
  x |> purrr::map_chr(abbreviate_one)
}
# x <- c(
#   "Jász-Nagykun-Szolnok",
#   "Bács-Kiskun",
#   "Hajdú-Bihar",
#   "Jono Tuke",
#   "Adam Ben Rohrlach",
#   "A (N = 12) (N = 1)"
# )
# abbreviate(x) |> print()

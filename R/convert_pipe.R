#' convert pipe
#'
#' @param x string for inclusion exclusion
#'
#' @returns commas are replaced by pipe
#'
#' @export
#' @examples
#' convert_pipe("bob, harry")
convert_pipe <- function(x) {
  x |> stringr::str_replace_all(",", "|") |> stringr::str_remove_all(" ")
}
# convert_pipe("bob, harry")

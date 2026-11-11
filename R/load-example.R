#' loads some example data
#'
#' @description
#' For use in the data wizard module
#'
#'
#' @param example name of example data to upload
#'
#' @returns example network
#'
#' @export
#' @examples
#' load_example()
load_example <- function(example = "example_network") {
  data <- tryCatch(
    get(example, "package:spIBDerverse"),
    error = function(e) {
      rlang::abort("That data does not exist\n")
    }
  )
  data
}
if (sys.nframe() == 5) {
  load_example("bob") |> print()
}

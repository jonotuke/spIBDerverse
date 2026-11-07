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
      message("That data does not exist\n")
      return(NULL)
    }
  )
  data
}
# load_example("example_network_4") |> print()

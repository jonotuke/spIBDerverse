#' helper function to pass stop messages into shiny
#'
#' @param expr expression to run
#'
#' @returns shiny validate message
validate_try <- function(expr) {
  tryCatch(
    expr,
    error = function(e) shiny::validate(conditionMessage(e))
  )
}
if (sys.nframe() == 5) {
  validate_try(sqrt(-1)) |> print()
  sqrt(-1)
}

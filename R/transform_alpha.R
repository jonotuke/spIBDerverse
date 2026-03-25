#' Transform vector to (a,b)
#'
#' @param x vector to transform
#' @param a lower bound of transform
#' @param b upper bound of transform
#'
#' @returns transformed vector
#'
#' @export
#' @examples
#' transform_alpha(runif(100))
transform_alpha <- function(x, a = 0, b = 1) {
  if (min(x, na.rm = TRUE) == max(x, na.rm = TRUE)) {
    stop("min is equal to max")
  }
  stopifnot(a < b)
  slope <- (b - a) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
  intercept <- a - slope * min(x, na.rm = TRUE)
  y <- intercept + slope * x
  y[is.na(y)] <- a
  y
}
# transform_alpha(V(example_network_2)$closeness, a = 1, b = 2) |> print()

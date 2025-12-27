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
  if (min(x) == max(x)) {
    stop("min is equal to max")
  }
  stopifnot(a < b)
  slope <- (b - a) / (max(x) - min(x))
  intercept <- a - slope * min(x)
  y <- intercept + slope * x
  y
}
# transform_alpha(1:3, a = 1, b = 2)

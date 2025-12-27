#' Get text font
#'
#' @description
#' Used to get contrasting text to a fill.
#'
#' @param x numeric vector to convert to colour
#' @param type whether to return the colour, or black / white for text
#'
#' @returns vector of colours
#'
#' @export
#' @examples
#' get_text_font(1:10)
#' get_text_font(1:10, "text")
get_text_font <- function(x, type = "fill") {
  fill <- colourvalues::colour_values(x)
  fill_hcl <- farver::decode_colour(fill, "rgb", "hcl")
  text <- ifelse(fill_hcl[, "l"] > 50, "black", "white")
  if (type == "fill") {
    return(fill)
  } else {
    text
  }
}
# get_text_font(1:10) |> scales::show_col()
# get_text_font(1:10, "text") |> scales::show_col()

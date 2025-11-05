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

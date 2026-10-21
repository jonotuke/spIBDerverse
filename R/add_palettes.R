#' fill discrete
#'
#' @param pal palette to use
#'
#' @returns appropriate scale
fill_discrete <- function(pal = 'ravenclaw') {
  if (pal == "ravenclaw") {
    pal <- harrypotter::scale_fill_hp_d("Ravenclaw")
  } else if (pal == "colourblind") {
    pal <- ggplot2::scale_fill_brewer(palette = "Set2")
  } else {
    pal <- ggplot2::scale_fill_discrete()
  }
  return(pal)
}
#' fill continuous
#'
#' @param pal palette to use
#'
#' @returns appropriate scale
fill_continuous <- function(pal = 'ravenclaw') {
  if (pal == "ravenclaw") {
    pal <- harrypotter::scale_fill_hp("Ravenclaw")
  } else if (pal == "colourblind") {
    pal <- ggplot2::scale_fill_viridis_c()
  } else {
    pal <- ggplot2::scale_fill_gradient()
  }
  return(pal)
}
#' colour discrete
#'
#' @param pal palette to use
#'
#' @returns appropriate scale
colour_discrete <- function(pal = 'ravenclaw') {
  if (pal == "ravenclaw") {
    pal <- harrypotter::scale_colour_hp_d("Ravenclaw")
  } else if (pal == "colourblind") {
    pal <- ggplot2::scale_colour_brewer(palette = "Set2")
  } else {
    pal <- ggplot2::scale_colour_discrete()
  }
  return(pal)
}
#' colour continuous
#'
#' @param pal palette to use
#'
#' @returns appropriate scale
colour_continuous <- function(pal = 'ravenclaw') {
  if (pal == "ravenclaw") {
    pal <- harrypotter::scale_colour_hp("Ravenclaw")
  } else if (pal == "colourblind") {
    pal <- ggplot2::scale_colour_viridis_c()
  } else {
    pal <- ggplot2::scale_colour_gradient()
  }
  return(pal)
}
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  p <- mpg |>
    ggplot(aes(displ, cty, colour = drv)) +
    geom_point(size = 4) +
    colour_discrete("")
  p |> print()
}

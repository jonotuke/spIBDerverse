plot_spatial_ergm <- function(ergm) {
  ergm
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  plot_spatial_ergm(ergm) |> print()
}

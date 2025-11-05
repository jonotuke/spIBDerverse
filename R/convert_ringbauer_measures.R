utils::globalVariables(
  c("grp1", "grp2", "density", "label", "text")
)
#' Convert ringbauer measures
#'
#' This converts the ringbauer measures into matrices of the correct form
#' for the plot function.
#'
#' @param RM A ringbauer measure tibble
#' @param abbr a boolean that when true will shorten the group names
#'
#' @return a list of three matrices: density, labels, and text colour
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |>
#' convert_ringbauer_measures()
convert_ringbauer_measures <- function(
  RM,
  abbr = TRUE
) {
  if (abbr) {
    RM <- RM |>
      dplyr::mutate(
        grp1 = abbreviate(grp1),
        grp2 = abbreviate(grp2)
      )
  }
  RM <- RM |> dplyr::select(grp1, grp2, density, label)
  RM <- RM |>
    dplyr::mutate(
      fill = get_text_font(density),
      text = get_text_font(density, "text")
    )
  grps <- unique(c(RM$grp1, RM$grp2))
  n_grps <- length(grps)
  M <- matrix(0, ncol = n_grps, nrow = n_grps)
  L <- matrix("", ncol = n_grps, nrow = n_grps)
  C <- matrix("white", ncol = n_grps, nrow = n_grps)
  for (i in 1:n_grps) {
    for (j in 1:n_grps) {
      M[i, j] <- RM |>
        dplyr::filter(grp1 == grps[i], grp2 == grps[j]) |>
        dplyr::pull(density)
      L[i, j] <- RM |>
        dplyr::filter(grp1 == grps[i], grp2 == grps[j]) |>
        dplyr::pull(label)
      C[i, j] <- RM |>
        dplyr::filter(grp1 == grps[i], grp2 == grps[j]) |>
        dplyr::pull(text)
    }
  }
  colnames(M) <- grps
  rownames(M) <- grps
  colnames(L) <- grps
  rownames(L) <- grps
  colnames(C) <- grps
  rownames(C) <- grps
  list(
    density = M,
    labels = L,
    text_colour = C
  )
}
# source("R/heatmap.R")
# get_ringbauer_matrix(
#   example_network,
#   "site"
# ) |>
#   plot_ringbauer_matrix() |>
#   print()

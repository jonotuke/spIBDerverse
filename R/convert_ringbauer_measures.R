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
#' @param addSize adds size to group labels
#' @param addPercent add percent to labels
#'
#' @return a list of three matrices: density, labels, and text colour
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |>
#' convert_ringbauer_measures()
convert_ringbauer_measures <- function(
  RM,
  abbr = TRUE,
  addSize = FALSE,
  addPercent = FALSE
) {
  if (abbr) {
    RM <- RM |>
      dplyr::mutate(
        grp1 = abbreviate(grp1),
        grp2 = abbreviate(grp2)
      )
  }
  if (addSize) {
    RM <- RM |>
      dplyr::mutate(
        grp1 = stringr::str_glue("{grp1} (n = {n1})"),
        grp2 = stringr::str_glue("{grp2} (n = {n2})")
      )
  }
  if (addPercent) {
    RM <- RM |>
      dplyr::mutate(
        label = stringr::str_glue("{label} ({round(density * 100, 2)}%)")
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

# get_ringbauer_measures(
#   example_network,
#   "site"
# ) |>
#   convert_ringbauer_measures(addPercent = TRUE) |>
#   print()

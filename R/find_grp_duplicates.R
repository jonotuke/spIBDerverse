#' sort labels
#'
#' @description
#' Takes two labels and sorts them so for example
#' A and B becomes A-B, and B and A becomes A-B.
#' This means that you can find duplicate edges in
#' an undirected network as they will have the same
#' label
#'
#'
#' @param label1 first label
#' @param label2 second label
#'
#' @returns label of form first-second
#'
#' @export
#' @examples
#' sort_label("A", "B")
#' sort_label("B", "A")
sort_label <- function(label1, label2) {
  c(label1, label2) |> sort() |> stringr::str_c(collapse = "-")
}
#' label_grp_duplicates
#'
#' @param df data frame with two group columns
#' @param grp1 name of first group col
#' @param grp2 name of second group col
#'
#' @returns df with extra col called .grp_label that has can be
#' used to remove duplicated rows
#'
#' @export
#' @examples
#' df <- tidyr::expand_grid(
#'   grp1 = LETTERS[1:3],
#'   grp2 = LETTERS[1:3]
#' ) |>
#' dplyr::mutate(
#'   value = 1:9
#' )
#' label_grp_duplicates(df, grp1, grp2)
label_grp_duplicates <- function(df, grp1, grp2) {
  df |>
    dplyr::rowwise() |>
    dplyr::mutate(
      .grp_label = sort_label({{ grp1 }}, {{ grp2 }})
    )
}
# df <- expand_grid(
#   grp1 = LETTERS[1:3],
#   grp2 = LETTERS[1:3]
# ) |>
#   mutate(
#     value = 1:9
#   )
# sort_label("A", "B")
# sort_label("B", "A")
# label_grp_duplicates(df, grp1, grp2) |> print()

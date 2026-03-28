add_stars <- function(pv) {
  stars <- dplyr::case_when(
    dplyr::between(pv, 0, 0.001) ~ "***",
    dplyr::between(pv, 0.001, 0.01) ~ "**",
    dplyr::between(pv, 0.01, 0.05) ~ "*",
    dplyr::between(pv, 0.05, 0.1) ~ ".",
    dplyr::between(pv, 0.1, 1) ~ ""
  )
  stars
}
# tibble(
#   pv = seq(0, 1, 0.001)
# ) |>
#   mutate(
#     stars = add_stars(pv)
#   ) |>
#   ggplot(aes(pv, stars)) +
#   geom_point()

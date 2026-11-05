pretty_var_name <- function(x) {
  lookup_map <- stats::setNames(
    internal_df()$full_name,
    internal_df()$name
  )
  x <- ifelse(
    x %in% names(lookup_map),
    lookup_map[x],
    x
  )
  x
}
pretty_choices <- function(x) {
  lookup <- internal_df()
  labels <- pretty_var_name(x)
  stats::setNames(x, labels)
}
pretty_col <- function(df) {
  lookup <- stats::setNames(
    internal_df()$name,
    internal_df()$full_name
  )
  df <- df |>
    dplyr::rename(dplyr::any_of(lookup))
  df
}
if (sys.nframe() == 5) {
  pretty_var_name(c(".degree", NA, "bob", ".louvain")) |> print()
  pretty_choices(c(".degree", "bob", ".louvain")) |> print()
  df <- tibble::tibble(
    .degree = 1:5,
    bob = 1:5,
    .louvain = 1:5
  )
  pretty_col(df) |> print()
}

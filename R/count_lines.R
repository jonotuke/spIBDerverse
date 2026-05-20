count_lines <- function(folder) {
  files <- fs::dir_ls(folder)
  message(stringr::str_glue("The number of files is {length(files)}"))
  df <- tibble::tibble(
    files = files
  )
  df <- df |>
    dplyr::mutate(
      lines = purrr::map(files, \(x) {
        lines <- readr::read_lines(x)
        length(lines)
      })
    ) |>
    tidyr::unnest(lines)
  message(stringr::str_glue("Total number of lines is {sum(df$lines)}"))
  df
}
if (sys.nframe() == 5) {
  count_lines("R") |> print()
}

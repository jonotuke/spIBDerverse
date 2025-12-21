name_file <- function(fig_ext, type) {
  ext <- dplyr::case_when(
    fig_ext == "PDF" ~ '.pdf',
    fig_ext == "PNG" ~ '.png',
    fig_ext == "JPEG" ~ '.jpeg'
  )
  paste0(lubridate::today(), "-", type, ext)
}

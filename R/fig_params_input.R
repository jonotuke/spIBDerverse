fig_params_input <- function(id) {
  shiny::tagList(
    shiny::numericInput(
      inputId = shiny::NS(id, "fig_width"),
      label = "Figure width",
      min = 6,
      max = 20,
      step = 1,
      value = 6
    ),
    shiny::numericInput(
      inputId = shiny::NS(id, "fig_height"),
      label = "Figure height",
      min = 6,
      max = 20,
      step = 1,
      value = 6
    ),
    shiny::radioButtons(
      inputId = shiny::NS(id, "fig_ext"),
      label = "Export type",
      choices = c("PDF", "PNG", "JPEG")
    )
  )
}

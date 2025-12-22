utils::globalVariables(
  c("displ", "cty")
)
exportplotInput <- function(id) {
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
    ),
    shiny::downloadButton(
      shiny::NS(id, "down"),
      "Save plot"
    )
  )
}
exportplotOutput <- function(id) {
  shiny::tagList(
    shiny::plotOutput(
      shiny::NS(id, "plot"),
      height = "800px"
    )
  )
}
exportplotServer <- function(id, type, store) {
  shiny::moduleServer(id, function(input, output, session) {
    output$down <- shiny::downloadHandler(
      filename = function() {
        ext <- dplyr::case_when(
          input$fig_ext == "PDF" ~ '.pdf',
          input$fig_ext == "PNG" ~ '.png',
          input$fig_ext == "JPEG" ~ '.jpeg'
        )
        paste0(lubridate::today(), "-", type, ext)
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          store$export(),
          width = input$fig_width,
          height = input$fig_height
        )
      }
    )
    output$plot <- shiny::renderPlot({
      store$export()
    })
  })
}
exportplotApp <- function() {
  ui <- shiny::fluidPage(
    exportplotInput("export_mpg"),
    exportplotOutput("export_mpg")
  )
  server <- function(input, output, session) {
    plots <- shiny::reactiveValues(
      export = shiny::reactive({
        ggplot2::mpg |>
          ggplot2::ggplot(ggplot2::aes(displ, cty)) +
          ggplot2::geom_point()
      })
    )
    exportplotServer("export_mpg", "network", plots)
  }
  shiny::shinyApp(ui, server)
}
# exportplotApp() |> print()

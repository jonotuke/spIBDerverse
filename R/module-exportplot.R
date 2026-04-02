utils::globalVariables(
  c("displ", "cty")
)
exportplotInput <- function(id) {
  shiny::tagList(
    shiny::numericInput(
      inputId = shiny::NS(id, "fig_width"),
      label = "Figure width (in)",
      min = 6,
      max = 20,
      step = 1,
      value = 6
    ),
    shiny::numericInput(
      inputId = shiny::NS(id, "fig_height"),
      label = "Figure height (in)",
      min = 6,
      max = 20,
      step = 1,
      value = 6
    ),
    shiny::sliderInput(
      shiny::NS(id, "res"),
      label = "Figure resolution (PPI)",
      min = 100,
      max = 600,
      step = 100,
      value = 300
    ),
    shiny::radioButtons(
      inputId = shiny::NS(id, "fig_ext"),
      label = "Export type",
      choices = c(
        "PDF" = 'pdf',
        "PNG" = 'png',
        "JPEG" = 'jpeg'
      )
    ),
    shiny::textInput(
      shiny::NS(id, "filename"),
      label = "Filename",
      value = "network.pdf"
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
exportplotServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$down <- shiny::downloadHandler(
      filename = function() {
        input$filename
      },
      content = function(file) {
        if ("recordedplot" %in% class(r$export())) {
          if (input$fig_ext == "pdf") {
            grDevices::pdf(
              file,
              width = input$fig_width,
              height = input$fig_height
            )
          } else if (input$fig_ext == "png") {
            grDevices::png(
              file,
              width = input$fig_width * input$res,
              height = input$fig_height * input$res,
              res = input$res
            )
          } else {
            grDevices::jpeg(
              file,
              width = input$fig_width * input$res,
              height = input$fig_height * input$res,
              res = input$res
            )
          }
          r$export() |> print()
          grDevices::dev.off()
        } else {
          ggplot2::ggsave(
            file,
            r$export(),
            width = input$fig_width,
            height = input$fig_height,
            dpi = input$res
          )
        }
      }
    )
    output$plot <- shiny::renderPlot({
      r$export()
    })
    shiny::observe({
      selected_value <- input$fig_ext
      shiny::updateTextInput(
        session = session,
        inputId = "filename",
        value = paste0(
          lubridate::today(),
          "-network.",
          selected_value
        )
      )
    })
  })
}
exportplotApp <- function(p) {
  ui <- shiny::fluidPage(
    exportplotInput("export_mpg"),
    exportplotOutput("export_mpg"),
  )

  server <- function(input, output, session) {
    r <- shiny::reactiveValues(
      export = shiny::reactive({
        p
      })
    )
    exportplotServer("export_mpg", r)
  }
  shiny::shinyApp(ui, server)
}
# p1 <-
#   ggplot2::mpg |>
#   ggplot2::ggplot(ggplot2::aes(displ, cty)) +
#   ggplot2::geom_point()

# get_ringbauer_measures(example_network, "site") |>
#   convert_ringbauer_measures() |>
#   plot_ringbauer(label_margin = 10, label_size = 8)
# p1 <- recordPlot()
# exportplotApp(p1) |> print()

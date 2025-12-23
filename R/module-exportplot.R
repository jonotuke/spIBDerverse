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
    ),
    shiny::verbatimTextOutput(
      shiny::NS(id, "debug")
    )
  )
}
exportplotServer <- function(id, type, store) {
  shiny::moduleServer(id, function(input, output, session) {
    output$down <- shiny::downloadHandler(
      filename = function() {
        # ext <- dplyr::case_when(
        #   input$fig_ext == "PDF" ~ '.pdf',
        #   input$fig_ext == "PNG" ~ '.png',
        #   input$fig_ext == "JPEG" ~ '.jpeg'
        # )
        # paste0(lubridate::today(), "-", type, ext)
        input$filename
      },
      content = function(file) {
        if ("recordedplot" %in% class(store$export())) {
          if (input$fig_ext == "pdf") {
            grDevices::pdf(
              file,
              width = input$fig_width,
              height = input$fig_height
            )
          } else if (input$fig_ext == "png") {
            grDevices::png(
              file,
              width = input$fig_width * 300,
              height = input$fig_height * 300,
              res = 300
            )
          } else {
            grDevices::jpeg(
              file,
              width = input$fig_width * 300,
              height = input$fig_height * 300,
              res = 300
            )
          }
          store$export() |> print()
          grDevices::dev.off()
        } else {
          ggplot2::ggsave(
            file,
            store$export(),
            width = input$fig_width,
            height = input$fig_height
          )
        }
      }
    )
    output$plot <- shiny::renderPlot({
      store$export()
    })
    output$debug <- shiny::renderPrint({
      print(class(store$export()))
    })
    shiny::observe({
      # Get the current value of the selected radio button
      selected_value <- input$fig_ext

      # Update the text input value based on the selection
      shiny::updateTextInput(
        session = session,
        inputId = "filename",
        value = paste0(lubridate::today(), "-network.", selected_value)
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
    plots <- shiny::reactiveValues(
      export = shiny::reactive({
        p
      })
    )
    exportplotServer("export_mpg", "network", plots)
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

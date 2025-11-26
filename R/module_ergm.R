ergmInput <- function(id, meta) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "preds"),
      "Select Predictors",
      choices = meta
    ),
    shiny::radioButtons(
      shiny::NS(id, "ergm_coef"),
      label = "ERGM type",
      choices = c(
        "Coefficients" = "theta",
        "Fold changes" = "phi"
      ),
      selected = "theta",
    ),
    shiny::checkboxInput(
      shiny::NS(id, "ergm_trim"),
      label = "Trim coefficients",
      value = TRUE
    )
  )
}
ergmOutput <- function(id) {
  shiny::tagList(
    shiny::h4("ERGMs BIC"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_aic_plot")
    ),
    shiny::downloadButton(
      shiny::NS(id, "bic_down"),
      "Download plot"
    ),
    shiny::tableOutput(
      shiny::NS(id, "ergm_aic_tab")
    ),
    shiny::h4("ERGMs coefficients"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_coef_plot")
    ),
    shiny::downloadButton(
      shiny::NS(id, "coef_down"),
      "Download plot"
    ),
  )
}
ergmServer <- function(id, df) {
  shiny::moduleServer(id, function(input, output, session) {
    ergm <- shiny::reactive(get_ergms(df(), input$preds))
    output$ergm_aic_tab <- shiny::renderTable({
      get_ergm_bic(ergm())
    })
    bic_plot <- shiny::reactive({
      plot_ergm_bic(ergm())
    })
    output$ergm_aic_plot <- shiny::renderPlot({
      bic_plot()
    })
    coef_plot <- shiny::reactive({
      plot_ergm_coef(
        ergm(),
        type = input$ergm_coef,
        trim = input$ergm_trim
      )
    })
    output$ergm_coef_plot <- shiny::renderPlot({
      coef_plot()
    })
    shiny::observeEvent(df(), {
      shiny::updateCheckboxGroupInput(
        session,
        "preds",
        choices = igraph::vertex_attr_names(df())
      )
    })
    output$bic_down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-ergm-bic.pdf")
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          bic_plot(),
          width = 10,
          height = 10
        )
      }
    )
    output$coef_down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-ergm-coef.pdf")
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          coef_plot(),
          width = 10,
          height = 10
        )
      }
    )
  })
}
ergmApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    ergmInput("ergm", meta),
    ergmOutput("ergm")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ergmServer("ergm", network)
  }
  shiny::shinyApp(ui, server)
}
# ergmApp(example_network) |> print()

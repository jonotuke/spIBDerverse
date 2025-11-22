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
    shiny::tableOutput(
      shiny::NS(id, "ergm_aic_tab")
    ),
    shiny::h4("ERGMs coefficients"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_coef_plot")
    )
  )
}
ergmServer <- function(id, df) {
  shiny::moduleServer(id, function(input, output, session) {
    ergm <- shiny::reactive(get_ergms(df(), input$preds))
    output$ergm_aic_plot <- shiny::renderPlot(
      plot_ergm_bic(ergm())
    )
    output$ergm_aic_tab <- shiny::renderTable({
      get_ergm_bic(ergm())
    })
    output$ergm_coef_plot <- shiny::renderPlot({
      plot_ergm_coef(
        ergm(),
        type = input$ergm_coef,
        trim = input$ergm_trim
      )
    })
    shiny::observeEvent(df(), {
      shiny::updateCheckboxGroupInput(
        session,
        "preds",
        choices = igraph::vertex_attr_names(df())
      )
    })
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

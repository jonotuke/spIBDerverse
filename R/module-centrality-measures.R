centralInput <- function(id, meta) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "names"),
      "Select Node names",
      choices = meta
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
    DT::dataTableOutput(
      shiny::NS(id, "ergm_aic_tab")
    ),
    shiny::h4("ERGMs coefficients"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_coef_plot"),
      height = "800px"
    ),
    shiny::downloadButton(
      shiny::NS(id, "coef_down"),
      "Download plot"
    ),
  )
}
centralServer <- function(id, df) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(df(), {
      shiny::updateCheckboxGroupInput(
        session,
        "names",
        choices = igraph::vertex_attr_names(df())
      )
    })
  })
}
centralApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    centralInput("central", meta),
    ergmOutput("ergm")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ergmServer("central", network)
  }
  shiny::shinyApp(ui, server)
}
# centralApp(example_network) |> print()

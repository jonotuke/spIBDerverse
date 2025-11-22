networksummaryInput <- function(id, vars) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "measure"),
      label = "Choose network statistic",
      choices = c(
        "Degree centrality" = "degree",
        "Eigenvalue centrality" = "eigen"
      )
    ),
    shiny::checkboxGroupInput(
      shiny::NS(id, "strata"),
      "Choose attributes to stratify on",
      choices = vars
    )
  )
}
networksummaryOutput <- function(id) {
  shiny::tableOutput(
    shiny::NS(id, "tab")
  )
}
networksummaryServer <- function(id, network) {
  shiny::moduleServer(id, function(input, output, session) {
    output$tab <- shiny::renderTable({
      get_network_measures(
        network(),
        measure = input$measure,
        var = input$strata
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateCheckboxGroupInput(
        session,
        "strata",
        choices = igraph::vertex_attr_names(network())
      )
    })
  })
}
networksummaryApp <- function(network_input) {
  vars <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    networksummaryInput("networksummary", vars),
    networksummaryOutput("networksummary")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    networksummaryServer("networksummary", network)
    all_inputs <- shiny::reactive({
      shiny::reactiveValuesToList(input)
    })
  }
  shiny::shinyApp(ui, server)
}
# networksummaryApp(example_network) |> print()

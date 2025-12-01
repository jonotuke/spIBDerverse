centralInput <- function(id, meta) {
  shiny::tagList(
    shiny::sliderInput(
      shiny::NS(id, "places"),
      label = "Choose decimal places for table",
      min = 0,
      max = 10,
      step = 1,
      value = 2
    )
  )
}
centralOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    )
  )
}
centralServer <- function(id, network) {
  shiny::moduleServer(id, function(input, output, session) {
    output$tab <- DT::renderDataTable({
      DT::datatable({
        get_centrality_measures(network())
      }) |>
        DT::formatRound(
          c(
            "closeness",
            "betweenness",
            "eigen_centrality"
          ),
          input$places
        )
    })
  })
}
centralApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    centralInput("central"),
    centralOutput("central")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    centralServer("central", network)
  }
  shiny::shinyApp(ui, server)
}
# centralApp(example_network) |> print()

edgeInput <- function(id) {
  shiny::tagList(
    shiny::textInput(
      shiny::NS(id, "node_inc"),
      "Node names to include"
    ),
    shiny::textInput(
      shiny::NS(id, "node_exc"),
      "Node names to exclude"
    )
  )
}
edgeOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    )
  )
}
edgeServer <- function(id, full_network) {
  shiny::moduleServer(id, function(input, output, session) {
    output$tab <- DT::renderDataTable({
      stopifnot(shiny::is.reactive(network))
      DT::datatable(
        get_edge_info(network())
      )
    })
    network <- shiny::reactive({
      filter_network(
        full_network(),
        node_inc = input$node_inc,
        node_exc = input$node_exc
      )
    })
  })
}
edgeApp <- function(network_input) {
  ui <- shiny::fluidPage(
    edgeInput("edge"),
    edgeOutput("edge")
  )
  network <- shiny::reactive({
    network_input
  })
  server <- function(input, output, session) {
    edgeServer("edge", network)
  }
  shiny::shinyApp(ui, server)
}
# edgeApp(example_network_2)

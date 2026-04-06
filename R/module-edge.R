edgeOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    )
  )
}
edgeServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$tab <- DT::renderDataTable({
      DT::datatable(
        get_edge_info(r$network())
      )
    })
  })
}
edgeApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  ui <- shiny::fluidPage(
    networkFilterInput("filter", all_vars),
    edgeOutput("edge")
  )
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    network_input
  })
  server <- function(input, output, session) {
    networkFilterServer("filter", r = r)
    edgeServer("edge", r = r)
  }
  shiny::shinyApp(ui, server)
}
# edgeApp(example_network_2)

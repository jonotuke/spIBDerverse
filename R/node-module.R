nodeOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "node_dt")
    )
  )
}

nodeServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$node_dt <- DT::renderDataTable({
      shiny::req(r$network())
      DT::datatable(
        get_node_info(r$network()),
        options = list(pageLength = 100)
      )
    })
  })
}
nodeApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  ui <- shiny::fluidPage(
    networkFilterInput("filter", all_vars),
    nodeOutput("node")
  )
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    network_input
  })
  server <- function(input, output, session) {
    nodeServer("node", r = r)
    networkFilterServer("filter", r = r)
  }
  shiny::shinyApp(ui, server)
}

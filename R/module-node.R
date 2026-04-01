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
      DT::datatable(
        get_node_info(r$network()),
        options = list(pageLength = 100)
      )
    })
  })
}
nodeApp <- function(network_input) {
  ui <- shiny::fluidPage(
    networkFilter("ibd"),
    nodeOutput("node")
  )
  r <- shiny::reactiveValues()
  r$network <- shiny::reactive({
    network_input
  })
  server <- function(input, output, session) {
    nodeServer("node", r = r)
    ibdServer('ibd', network_input, r = r)
  }
  shiny::shinyApp(ui, server)
}

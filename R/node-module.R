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

      node_info <- get_node_info(r$network())
      num_cols <- names(purrr::keep(node_info, is.numeric))

      dt <- DT::datatable(
        node_info,
        options = list(pageLength = 100)
      )

      if (length(num_cols) > 0) {
        dt <- DT::formatRound(dt, columns = num_cols, digits = 2)
      }

      dt
    })
  })
}
nodeApp <- function(input_network) {
  all_vars <- get_node_attributes(input_network)
  edge_vars <- igraph::edge_attr_names(input_network)
  ui <- shiny::fluidPage(
    networkFilterInput(
      "filter",
      all_vars = all_vars,
      edge_vars = edge_vars
    ),
    nodeOutput("node")
  )
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    input_network
  })
  server <- function(input, output, session) {
    nodeServer("node", r = r)
    networkFilterServer("filter", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  nodeApp(example_network) |> print()
}

nodeOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    DT::dataTableOutput(
      ns("node_dt")
    ),
    shiny::downloadButton(
      ns("download"),
      label = "Download node table"
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
    output$download <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-node-table.tsv")
      },
      content = function(file) {
        readr::write_tsv(
          get_node_info(r$network()),
          file
        )
      }
    )
  })
}
nodeApp <- function(input_network) {
  all_vars <- get_node_attributes(input_network)
  edge_vars <- igraph::edge_attr_names(input_network)
  ui <- shiny::fluidPage(
    prunerInput(
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
    prunerServer("filter", r = r)
  }
  shiny::shinyApp(ui, server)
}

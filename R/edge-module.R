#' edge output
#' @noRd
edgeOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    DT::dataTableOutput(
      ns("tab")
    ),
    shiny::downloadButton(
      ns("download"),
      label = "Download node table"
    )
  )
}
#' edge server
#' @noRd
edgeServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$tab <- DT::renderDataTable({
      DT::datatable(
        get_edge_info(r$network())
      )
    })
    output$download <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-edge-table.tsv")
      },
      content = function(file) {
        readr::write_tsv(
          get_edge_info(r$network()),
          file
        )
      }
    )
  })
}
#' edge app
#' @noRd
edgeApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  edge_vars <- igraph::edge_attr_names(network_input)
  ui <- shiny::fluidPage(
    prunerInput("filter", all_vars, edge_vars),
    edgeOutput("edge")
  )
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    network_input
  })
  r$network <- shiny::reactive({
    network_input
  })
  server <- function(input, output, session) {
    prunerServer("filter", r = r)
    edgeServer("edge", r = r)
  }
  shiny::shinyApp(ui, server)
}

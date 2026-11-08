#' Get network edge information
#'
#' @param g ibd network object
#'
#' @return tibble of node information
#' @export
#'
#' @examples
#' get_edge_info(example_network_2)
get_edge_info <- function(g) {
  igraph::as_data_frame(g, what = "edges") |>
    tibble::as_tibble() |>
    dplyr::mutate(
      dplyr::across(dplyr::starts_with("frac"), \(x) round(x, 4)),
      dplyr::across(dplyr::starts_with("max"), \(x) round(x, 2)),
      dplyr::across(dplyr::starts_with("sum"), \(x) round(x, 2)),
      dplyr::across(wij, \(x) round(x, 2)),
    )
}
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

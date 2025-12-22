networkstatsInput <- function(id, meta) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "strata"),
      "Choose attributes to stratify on",
      choices = meta
    ),
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
networkstatsOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    ),
    shiny::downloadButton(
      shiny::NS(id, "down"),
      "Download table"
    )
  )
}
networkstatsServer <- function(id, network) {
  shiny::moduleServer(id, function(input, output, session) {
    central_df <- shiny::reactive({
      get_centrality_measures(network(), input$strata)
    })
    output$tab <- DT::renderDataTable({
      DT::datatable({
        central_df()
      }) |>
        DT::formatRound(
          c("degree", "closeness", "betweenness", "eigen_centrality"),
          input$places
        )
    })
    output$down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-centrality.tsv")
      },
      content = function(file) {
        readr::write_tsv(
          central_df(),
          file
        )
      }
    )
  })
}
networkstatsApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    networkstatsInput("central", meta),
    networkstatsOutput("central")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    networkstatsServer("central", network)
  }
  shiny::shinyApp(ui, server)
}
# networkstatsApp(example_network) |> print()

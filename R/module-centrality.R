centralityInput <- function(id, cat_vars) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "strata"),
      "Choose attributes to stratify on",
      choices = cat_vars
    ),
    shiny::numericInput(
      shiny::NS(id, "places"),
      label = "Choose decimal places for table",
      min = 0,
      max = 10,
      step = 1,
      value = 2
    ),
    shiny::radioButtons(
      shiny::NS(id, "measure"),
      "Centrality measure to plot",
      choices = c(
        "Degree" = ".degree",
        "Closeness" = ".closeness",
        "Betweenness" = ".betweenness",
        "Eigencentrality" = ".eigencentrality"
      ),
      selected = ".degree"
    )
  )
}
centralityOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    ),
    shiny::downloadButton(
      shiny::NS(id, "down"),
      "Download table"
    ),
    shiny::plotOutput(
      shiny::NS(id, "hist")
    ),
    shiny::actionButton(
      shiny::NS(id, "save"),
      "Set as export plot"
    )
  )
}
centralityServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    central_df <- shiny::reactive({
      get_centrality_measures(r$network(), input$strata)
    })
    output$tab <- DT::renderDataTable({
      DT::datatable({
        central_df()
      }) |>
        DT::formatRound(
          c(".degree", ".closeness", ".betweenness", ".eigencentrality"),
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
    output$hist <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      plot_centrality(
        r$network(),
        measure = input$measure,
        facets = input$strata
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateCheckboxGroupInput(
        session,
        "strata",
        choices = c(
          get_node_attributes(r$full_network(), "cat")
        )
      )
    })
    shiny::observeEvent(input$save, {
      r$export <- shiny::reactive(
        p()
      )
    })
  })
}
centralityApp <- function(network_input) {
  cat_var <- get_node_attributes(network_input, "cat")
  ui <- shiny::fluidPage(
    centralityInput("central", cat_var),
    centralityOutput("central")
  )
  server <- function(input, output, session) {
    r <- shiny::reactiveValues()

    r$network <- shiny::reactive(network_input)
    r$full_network <- shiny::reactive(network_input)
    centralityServer("central", r = r)
  }
  shiny::shinyApp(ui, server)
}
# centralityApp(example_network) |> print()

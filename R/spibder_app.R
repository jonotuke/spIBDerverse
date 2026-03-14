utils::globalVariables(
  c("example_network")
)
#' spIBDerverse shiny app
#'
#' @param input_network an igraph network object for the IBD data
#'
#' @return nothing
#' @export
spibder_app <- function(input_network = NULL) {
  if (is.null(input_network)) {
    input_network <- example_network
  }
  meta <- igraph::vertex_attr_names(input_network)
  edge_meta <- igraph::edge_attr_names(input_network)
  ui <- shiny::fluidPage(
    prompter::use_prompt(),
    shiny::titlePanel("shiny spIBDer"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::conditionalPanel(
          condition = "input.tabs == 'Upload IBD'",
          ibdInput("ibd")
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Edge table'",
          edgeInput("edge")
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Network plot'",
          networkplotInput("networkplot", meta, edge_meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Centrality measures'",
          centralityInput("central", meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Dynamic map'",
          leafletInput("leaflet", meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Static map'",
          staticmapInput("staticmap", meta, edge_meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Ringbauer matrix'",
          ringbauerInput("ringbauer", meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'ERGM models'",
          ergmInput("ergm", meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Export plot'",
          exportplotInput("export")
        ),
        shiny::downloadButton(
          "bookmark",
          "Save analysis state"
        ) |>
          prompter::add_prompt(message = "This is a tool tip")
      ),
      shiny::mainPanel(
        shiny::tabsetPanel(
          id = "tabs",
          shiny::tabPanel(
            title = "Upload IBD",
            ibdOutput("ibd")
          ),
          shiny::tabPanel(
            title = "Edge table",
            edgeOutput("edge")
          ),
          shiny::tabPanel(
            title = "Network summary",
            shiny::tableOutput("summary")
          ),
          shiny::tabPanel(
            title = "Network plot",
            networkplotOutput("networkplot")
          ),
          shiny::tabPanel(
            title = "Centrality measures",
            centralityOutput("central")
          ),
          shiny::tabPanel(
            title = "Dynamic map",
            leafletOutput("leaflet")
          ),
          shiny::tabPanel(
            title = "Static map",
            staticmapOutput("staticmap")
          ),
          shiny::tabPanel(
            title = "Ringbauer matrix",
            ringbauerOutput("ringbauer")
          ),
          shiny::tabPanel(
            title = "ERGM models",
            ergmOutput("ergm")
          ),
          shiny::tabPanel(
            title = "Export plot",
            exportplotOutput("export")
          ),
          shiny::tabPanel(
            title = "Debugging",
            shiny::verbatimTextOutput(outputId = "debug")
          )
        )
      )
    )
  )
  server <- function(input, output, session) {
    ## Network plot ----
    networkplotServer("networkplot", network, plots)
    ## Network summary ----
    output$summary <- shiny::renderTable({
      get_network_summary(network())
    })
    ## Centrality measures
    centralityServer("central", network)
    ## Leaflet plot ----
    leafletServer("leaflet", network)
    ## Static map
    staticmapServer("staticmap", network, plots)
    # Ringbauer matrix ----
    ringbauerServer("ringbauer", network, plots)
    # ERGMs ----
    ergmServer("ergm", network, plots)
    # IBD ----
    network <- ibdServer("ibd", input_network)
    # Edge ----
    edgeServer("edge", network)
    # EXPORT <----
    snapshot <- shiny::reactive({
      shiny::reactiveValuesToList(input)
    })
    output$bookmark <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), ".rds")
      },
      content = function(file) {
        readr::write_rds(snapshot(), file)
      }
    )
    plots <- shiny::reactiveValues(
      export = shiny::reactive({
        plot_default_image()
      })
    )
    exportplotServer("export", "network", plots)
    # DEBUG ----
    output$debug <- shiny::renderPrint({
      print(network())
    })
  }
  shiny::shinyApp(ui, server)
}

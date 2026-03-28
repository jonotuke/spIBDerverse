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

  cat_vars <- get_node_attributes(input_network, "cat")
  all_vars <- get_node_attributes(input_network)
  edge_vars <- igraph::edge_attr_names(input_network)
  options(shiny.maxRequestSize = Inf)
  ui <- shiny::fluidPage(
    theme = bslib::bs_theme(version = 5),
    shiny::titlePanel("SpIBDer-verse: Network Analyses"),
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
          networkplotInput(
            "networkplot",
            cat_vars = cat_vars,
            all_vars = all_vars,
            edge_vars = edge_vars
          )
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Centrality measures'",
          centralityInput("central", cat_vars)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Dynamic map'",
          leafletInput("leaflet", all_vars)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Static map'",
          staticmapInput(
            "staticmap",
            all_vars = all_vars,
            cat_vars = cat_vars,
            edge_vars = edge_vars
          )
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Ringbauer matrix'",
          ringbauerInput("ringbauer", cat_vars)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'ERGM models'",
          ergmInput("ergm", all_vars)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Export plot'",
          exportplotInput("export")
        ),
        shiny::downloadButton(
          "bookmark",
          "Save analysis state"
        )
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
            title = "Network summary",
            shiny::tableOutput("summary")
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
    centralityServer("central", network, plots)
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

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

  ui <- shiny::fluidPage(
    shiny::titlePanel("shiny spIBDer"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::conditionalPanel(
          condition = "input.tabs == 'Upload IBD'",
          ibdInput("ibd")
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Network plot'",
          networkplotInput("networkplot", meta),
          networksummaryInput("networksummary", meta)
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Centrality measures'",
          centralInput("central")
        ),
        shiny::conditionalPanel(
          condition = "input.tabs == 'Geography plot'",
          leafletInput("leaflet", meta)
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
          "Download snapshot"
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
            title = "Network plot",
            networkplotOutput("networkplot"),
            networksummaryOutput("networksummary"),
            shiny::plotOutput("test")
          ),
          shiny::tabPanel(
            title = "Centrality measures",
            centralOutput("central")
          ),
          shiny::tabPanel(
            title = "Geography plot",
            leafletOutput("leaflet")
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
    ## Centrality measures
    centralServer("central", network)
    ## Leaflet plot ----
    leafletServer("leaflet", network)
    # Network measures ----
    networksummaryServer("networksummary", network)
    # Ringbauer matrix ----
    ringbauerServer("ringbauer", network)
    # ERGMs ----
    ergmServer("ergm", network)
    # IBD ----
    network <- ibdServer("ibd", input_network)
    # DATA ----
    ## Network ----
    # network <- shiny::reactive({
    #   input_network
    # })
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
        ggplot2::mpg |>
          ggplot2::ggplot(ggplot2::aes(displ, cty)) +
          ggplot2::geom_point()
      })
    )
    exportplotServer(
      "export",
      "network",
      plots
    )
    # DEBUG ----
    output$debug <- shiny::renderPrint({
      print(network())
    })
  }
  shiny::shinyApp(ui, server)
}

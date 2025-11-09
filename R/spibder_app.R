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
          condition = "input.tabs == 'Network plot'",
          networkplotInput("networkplot", meta),
          networksummaryInput("networksummary", meta)
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
        )
      ),
      shiny::mainPanel(
        shiny::tabsetPanel(
          id = "tabs",
          shiny::tabPanel(
            title = "Network plot",
            networkplotOutput("networkplot"),
            networksummaryOutput("networksummary")
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
          )
        )
      )
    )
  )
  server <- function(input, output, session) {
    ## Network plot ----
    networkplotServer("networkplot", network())
    ## Leaflet plot ----
    leafletServer("leaflet", network())
    # Network measures ----
    networksummaryServer("networksummary", network())
    # Ringbauer matrix ----
    ringbauerServer("ringbauer", network())
    # ERGMs ----
    ergmServer("ergm", network())
    # DATA ----
    ## Network ----
    network <- shiny::reactive({
      input_network
    })
  }
  shiny::shinyApp(ui, server)
}

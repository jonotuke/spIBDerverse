utils::globalVariables(
  c("example_network")
)
spibder_app <- function() {
  meta <- igraph::vertex_attr_names(example_network)

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
    # ERGMs ----
    ergmServer("ergm", network())
    # DATA ----
    ## Network ----
    network <- shiny::reactive({
      example_network
    })
  }
  shiny::shinyApp(ui, server)
}

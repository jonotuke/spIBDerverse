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
          shiny::hr(),
          shiny::h4("Network statistics"),
          networksummaryInput("networksummary", meta),
          shiny::hr()
        )
      ),
      shiny::mainPanel(
        shiny::tabsetPanel(
          id = "tabs",
          shiny::tabPanel(
            title = "Network plot",
            networkplotOutput("networkplot"),
            networksummaryOutput("networksummary")
          )
        )
      )
    )
  )
  server <- function(input, output, session) {
    # PLOTS ----
    ## Network plot ----
    networkplotServer(
      "networkplot",
      gg_net()
    )
    # TABS ----
    networksummaryServer(
      "networksummary",
      network()
    )
    # DATA ----
    ## Network ----
    network <- shiny::reactive({
      example_network
    })
    ## ggnet ----
    gg_net <- shiny::reactive({
      set.seed(input$seed)
      ggnetwork::ggnetwork(network())
    })
  }
  shiny::shinyApp(ui, server)
}

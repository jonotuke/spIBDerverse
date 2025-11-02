spibder_app <- function() {
  # Get vertex names from example network
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
          shiny::selectInput(
            "network_stat_id",
            label = "Choose network statistic",
            choices = c(
              "Degree centrality" = "degree",
              "Eigenvalue centrality" = "eigen"
            )
          ),
          shiny::checkboxInput(
            "add_shape",
            "Stratify on shape",
            value = TRUE
          ),
          shiny::checkboxInput(
            "add_fill",
            "Stratify on fill",
            value = TRUE
          ),
          shiny::hr()
        )
      ),
      shiny::mainPanel(
        shiny::tabsetPanel(
          id = "tabs",
          shiny::tabPanel(
            title = "Network plot",
            networkplotOutput("networkplot"),
            shiny::tableOutput("network_stats")
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

spibder_app <- function() {
  # Get vertex names from example network
  meta <- igraph::vertex_attr_names(example_network)

  ui <- shiny::fluidPage(
    shiny::titlePanel("shiny spIBDer"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::conditionalPanel(
          condition = "input.tabs == 'Network plot'",
          shiny::numericInput("seed", "Set seed", value = 1000),
          shiny::h4("Shape variable"),
          shiny::selectInput(
            inputId = "shape_id",
            label = NULL,
            choices = c("", meta),
            selected = ""
          ),
          shiny::hr(),
          shiny::h4("Fill variable"),
          shiny::selectInput(
            "fill_id",
            label = NULL,
            choices = c("", meta),
            selected = ""
          ),
          shiny::hr(),
          shiny::checkboxInput(
            "connected",
            "Only show connected nodes",
            value = TRUE
          ),
          shiny::sliderInput(
            "node_size",
            "Node size",
            min = 1,
            max = 20,
            value = 4
          ),
          shiny::sliderInput(
            "label_size",
            "Label size",
            min = 1,
            max = 20,
            value = 4
          ),
          shiny::checkboxInput(
            "add_label",
            "Add labels",
            value = FALSE
          ),
          shiny::textInput(
            "label_inc",
            "Labels to include"
          ),
          shiny::textInput(
            "label_exc",
            "Labels to exclude"
          ),
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
            shiny::plotOutput("network_plot", height = "800px"),
            shiny::tableOutput("network_stats")
          )
        )
      )
    )
  )
  server <- function(input, output, session) {
    # PLOTS ----
    ## Network plot ----
    output$network_plot <- shiny::renderPlot({
      plot_ggnet(
        gg_net(),
        shape = input$shape_id,
        fill = input$fill_id,
        node_size = input$node_size,
        labels = input$add_label,
        text_size = input$label_size,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        connected = input$connected
      )
    })

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

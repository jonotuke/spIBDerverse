networkplotInput <- function(id, meta) {
  shiny::tagList(
    shiny::numericInput(
      shiny::NS(id, "seed"),
      label = "Set seed",
      value = 1000
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "shape_id"),
      label = "Shape variable",
      choices = c("", meta),
      selected = ""
    ),
    shiny::selectInput(
      shiny::NS(id, "fill_id"),
      label = "Fill variable",
      choices = c("", meta),
      selected = ""
    ),
    shiny::selectInput(
      shiny::NS(id, "alpha_id"),
      label = "Alpha variable",
      choices = c("", "degree", "betweenness", "closeness", "eigen_centrality"),
      selected = ""
    ),
    shiny::radioButtons(
      shiny::NS(id, "solo_nodes"),
      label = "Isolated nodes",
      choices = c("Show", "Grey out", "Hide"),
      selected = "Show"
    ),
    shiny::sliderInput(
      shiny::NS(id, "node_size"),
      "Node size",
      min = 1,
      max = 20,
      value = 10
    ),
    shiny::sliderInput(
      shiny::NS(id, "label_size"),
      "Label size",
      min = 1,
      max = 20,
      value = 4
    ),
    shiny::checkboxInput(
      shiny::NS(id, "add_label"),
      "Add labels",
      value = FALSE
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "label_id"),
      label = "Label variable",
      choices = c("", meta),
      selected = ""
    ),
    shiny::textInput(
      shiny::NS(id, "label_inc"),
      "Labels to include"
    ),
    shiny::textInput(
      shiny::NS(id, "label_exc"),
      "Labels to exclude"
    )
  )
}

networkplotOutput <- function(id) {
  shiny::tagList(
    shiny::plotOutput(
      shiny::NS(id, "plot"),
      height = "800px"
    ),
    shiny::actionButton(
      shiny::NS(id, "save"),
      "Set as export plot"
    ),
    shiny::verbatimTextOutput(
      shiny::NS(id, "debug")
    )
  )
}

networkplotServer <- function(id, network, store) {
  shiny::moduleServer(id, function(input, output, session) {
    plot_network <- shiny::reactive({
      if (input$alpha_id != "") {
        add_alpha(network(), measure = input$alpha_id)
      } else {
        network()
      }
    })
    ggnet <- shiny::reactive({
      set.seed(input$seed)
      ggnetwork::ggnetwork(plot_network())
    })
    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      plot_ggnet(
        ggnet(),
        shape_col = input$shape_id,
        fill_col = input$fill_id,
        node_size = input$node_size,
        labels = input$add_label,
        label_col = input$label_id,
        text_size = input$label_size,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        connected = input$solo_nodes
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "shape_id",
        choices = c(
          "",
          igraph::vertex_attr_names(network())
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "fill_id",
        choices = c(
          "",
          igraph::vertex_attr_names(network())
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "label_id",
        choices = c(
          "",
          igraph::vertex_attr_names(network())
        )
      )
    })
    shiny::observeEvent(input$save, {
      store$export <- shiny::reactive(
        p()
      )
    })
    output$debug <- shiny::renderPrint({
      print(input$fill_id)
      print(input$alpha_id)
      print(network())
      print(plot_network())
    })
  })
}
networkplotApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    title = "Network plot",
    networkplotInput("networkplot", meta),
    networkplotOutput("networkplot"),
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(
      network_input
    )
    networkplotServer(
      "networkplot",
      network = network,
      plots
    )
    plots <- shiny::reactiveValues(
      export = shiny::reactive({
        plot_default_image()
      })
    )
    exportplotServer(
      "exportplot",
      "network",
      plots$export
    )
  }
  shiny::shinyApp(ui, server)
}
# networkplotApp(example_network_2) |> print()

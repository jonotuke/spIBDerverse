networkplotInput <- function(id, cat_vars, all_vars, edge_vars) {
  shiny::tagList(
    shiny::numericInput(
      shiny::NS(id, "seed"),
      label = "Set seed",
      value = 1000
    ) |>
      bslib::popover(
        "Number to generate new network layout. Change this number to rearrange the nodes."
      ),
    shiny::selectInput(
      shiny::NS(id, "fill"),
      label = "Choose node fill column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "shape"),
      label = "Choose node shape column",
      choices = c("none", cat_vars),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "edge"),
      label = "Choose edge column",
      choices = c("none", edge_vars),
      selected = "none"
    ),
    shiny::checkboxInput(
      shiny::NS(id, "edge_legend"),
      label = "Add edge legend",
      value = TRUE
    ),
    shiny::selectInput(
      shiny::NS(id, "edge_trans"),
      label = "Edge Transformation",
      choices = c(
        "None" = "identity",
        "Log10" = "log10"
      ),
      selected = "identity",
      width = "100%"
    ) |>
      bslib::popover(
        "Method to scale the edge values and legend. Either \"None\" or a \"log10\"transformation."
      ),
    shiny::selectInput(
      shiny::NS(id, "node_centrality"),
      label = "Show node centrality",
      choices = c(
        "none",
        "degree",
        "betweenness",
        "closeness",
        "eigencentrality"
      ),
      selected = "none",
      width = "100%"
    ) |>
      bslib::popover(
        htmltools::HTML(
          "Degree: the number of other individuals an individual is connected to. High values indicate an individual has more relatives.
          <br><br>
            Closeness: the inverse of the sum of the shortest paths to all other nodes. Low values indicate that an individual is relatively closely related to all others.
          <br><br>
            Betweeness: how frequently an individual appears on the shortest path between all pairs of individuals. High values indicate that an individual is important to connecting the network.
          <br><br>
            Eigencentrality: a measure of \"prestige\" on the network. High values indicate that an individual is connected to many highly-connected individuals.",
        )
      ),
    shiny::radioButtons(
      shiny::NS(id, "connected"),
      label = "Unconnected nodes",
      choices = c("Show", "Grey out", "Hide"),
      selected = "Show"
    ) |>
      bslib::tooltip(
        "How to treat the unconnected nodes in the network plot."
      ),
    shiny::numericInput(
      shiny::NS(id, "node_size"),
      "Node size",
      min = 1,
      max = 20,
      value = 10,
      step = 1
    ),
    shiny::numericInput(
      shiny::NS(id, "label_size"),
      "Label size",
      min = 1,
      max = 20,
      value = 4
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "label"),
      label = "Label variable",
      choices = c("none", all_vars),
      selected = "none"
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
    )
  )
}

networkplotServer <- function(id, network, store) {
  shiny::moduleServer(id, function(input, output, session) {
    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      plot_network(
        network(),
        seed = input$seed,
        connected = input$connected,
        edge = input$edge,
        node_size = input$node_size,
        edge_legend = input$edge_legend,
        edge_trans = input$edge_trans,
        label = input$label,
        label_size = input$label_size,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        fill = input$fill,
        shape = input$shape,
        node_centrality = input$node_centrality
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "shape",
        choices = c(
          "none",
          get_node_attributes(network(), "cat")
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "fill",
        choices = c(
          "none",
          get_node_attributes(network())
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "edge",
        choices = c(
          "none",
          igraph::edge_attr_names(network())
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "label",
        choices = c(
          "none",
          get_node_attributes(network())
        )
      )
    })
    shiny::observeEvent(input$save, {
      store$export <- shiny::reactive(
        p()
      )
    })
  })
}
networkplotApp <- function(network_input) {
  cat_vars <- get_node_attributes(network_input, "cat")
  all_vars <- get_node_attributes(network_input)
  edge_vars <- igraph::edge_attr_names(network_input)
  ui <- shiny::fluidPage(
    title = "Network plot",
    networkplotInput(
      "networkplot",
      cat_vars = cat_vars,
      all_vars = all_vars,
      edge_vars = edge_vars
    ),
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

networkplotInput <- function(id, cat_vars, all_vars, edge_vars) {
  shiny::tagList(
    shiny::numericInput(
      shiny::NS(id, "seed"),
      label = "Set seed",
      value = 1000
    ) |>
      prompter::add_prompt(
        message = "Number to generate new network layout.\nChange this number to rearrange the nodes.",
        type = "info",
        position = "right",
        rounded = TRUE
      ),
    shiny::selectInput(
      shiny::NS(id, "fill_id"),
      label = "Choose node fill column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "shape_id"),
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
      prompter::add_prompt(
        message = "Method to scale the edge values and\n
legend. Either \"None\" or a \"log10\"\ntransformation.",
        type = "info",
        position = "right",
        rounded = TRUE
      ),
    shiny::selectInput(
      shiny::NS(id, "centrality"),
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
      prompter::add_prompt(
        message = "Degree: the number of other individuals an\n
individual is connected to. High values indicate\n
an individual has more relatives.\n\n
Closeness: the inverse of the sum of the shortest\n
paths to all other nodes. Low values indicate that\n
an individual is relatively closely related to all others.\n\n
Betweeness: how frequently an individual appears on the shortest\n
path between all pairs of individuals. High values indicate that \n
an individual is important to connecting the network.\n\n
Eigencentrality: a measure of \"prestige\" on the network. \n
High values indicate that an individual is connected to many\n
highly-connected individuals.
",
        type = "info",
        position = "right",
        rounded = TRUE
      ),
    shiny::radioButtons(
      shiny::NS(id, "solo_nodes"),
      label = "Unconnected nodes",
      choices = c("Show", "Grey out", "Hide"),
      selected = "Show"
    ) |>
      prompter::add_prompt(
        message = "How to treat the unconnected nodes in the network plot.",
        type = "info",
        position = "right",
        size = "large",
        rounded = TRUE
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
    shiny::checkboxInput(
      shiny::NS(id, "add_label"),
      "Add labels",
      value = FALSE
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "label_id"),
      label = "Label variable",
      choices = c("", all_vars),
      selected = ""
    ),
    shiny::radioButtons(
      shiny::NS(id, "text_col"),
      label = "Text colour",
      choices = c("black", "white"),
      selected = "black"
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
      set.seed(input$seed)
      plot_network(
        network(),
        shape_col = input$shape_id,
        fill_col = input$fill_id,
        node_alpha_col = input$centrality,
        edge_col = input$edge,
        edge_legend = input$edge_legend,
        edge_trans = input$edge_trans,
        node_size = input$node_size,
        labels = input$add_label,
        label_col = input$label_id,
        text_size = input$label_size,
        text_col = input$text_col,
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
          "none",
          get_node_attributes(network(), "cat")
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "fill_id",
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
        "label_id",
        choices = c(
          "",
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

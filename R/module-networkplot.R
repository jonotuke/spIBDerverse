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
    network_ui(id, all_vars, cat_vars, edge_vars)
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

networkplotServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      if (is.null(r$network())) {
        return(NULL)
      }
      plot_network(
        r$network(),
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
        node_centrality = input$node_centrality,
        pal = input$pal
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "shape",
        choices = c(
          "none",
          get_node_attributes(r$full_network(), "cat")
        )
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "fill",
        choices = c(
          "none",
          get_node_attributes(r$full_network())
        )
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "edge",
        choices = c(
          "none",
          igraph::edge_attr_names(r$full_network())
        )
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "label",
        choices = c(
          "none",
          get_node_attributes(r$full_network())
        )
      )
    })
    shiny::observeEvent(input$save, {
      r$export <- shiny::reactive(
        p()
      )
    })
  })
}
networkplotApp <- function(network_input) {
  cat_vars <- get_node_attributes(network_input, "cat")
  all_vars <- get_node_attributes(network_input)
  edge_vars <- igraph::edge_attr_names(network_input)

  r <- shiny::reactiveValues()
  r$export <- shiny::reactive({
    plot_default_image()
  })
  r$network <- shiny::reactive(
    network_input
  )

  ui <- shiny::fluidPage(
    title = "Network plot",
    networkplotInput(
      "networkplot",
      cat_vars = cat_vars,
      all_vars = all_vars,
      edge_vars = edge_vars
    ),
    networkplotOutput("networkplot"),
    shiny::plotOutput("export")
  )

  server <- function(input, output, session) {
    networkplotServer(
      "networkplot",
      r = r
    )

    exportplotServer(
      "exportplot",
      r = r
    )

    output$export <- shiny::renderPlot({
      r$export()
    })
  }
  shiny::shinyApp(ui, server)
}
# networkplotApp(example_network_2) |> print()

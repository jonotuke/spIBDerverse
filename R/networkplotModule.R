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
    shiny::checkboxInput(
      shiny::NS(id, "connected"),
      "Only show connected nodes",
      value = TRUE
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
  shiny::plotOutput(
    shiny::NS(id, "plot"),
    height = "800px"
  )
}

networkplotServer <- function(id, network) {
  shiny::moduleServer(id, function(input, output, session) {
    ggnet <- shiny::reactive({
      set.seed(input$seed)
      ggnetwork::ggnetwork(network)
    })
    output$plot <- shiny::renderPlot({
      plot_ggnet(
        ggnet(),
        shape_col = input$shape_id,
        fill_col = input$fill_id,
        node_size = input$node_size,
        labels = input$add_label,
        text_size = input$label_size,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        connected = input$connected
      )
    })
  })
}
networkplotApp <- function(network) {
  meta <- igraph::vertex_attr_names(network)
  ui <- shiny::fluidPage(
    networkplotInput("networkplot", meta),
    networkplotOutput("networkplot")
  )
  server <- function(input, output, session) {
    networkplotServer(
      "networkplot",
      network
    )
  }
  shiny::shinyApp(ui, server)
}
# networkplotApp(example_network) |> print()

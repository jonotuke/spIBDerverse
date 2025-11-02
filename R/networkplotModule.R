networkplotInput <- function(id, meta) {
  shiny::tagList(
    shiny::numericInput(
      shiny::NS(id, "seed"),
      "Set seed",
      value = 1000
    ),
    shiny::h4("Shape variable"),
    shiny::selectInput(
      inputId = shiny::NS(id, "shape_id"),
      label = NULL,
      choices = c("", meta),
      selected = ""
    ),
    shiny::hr(),
    shiny::h4("Fill variable"),
    shiny::selectInput(
      shiny::NS(id, "fill_id"),
      label = NULL,
      choices = c("", meta),
      selected = ""
    ),
    shiny::hr(),
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
      value = 4
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
    NS(id, "plot"),
    height = "800px"
  )
}

networkplotServer <- function(id, df) {
  moduleServer(id, function(input, output, session) {
    output$plot <- shiny::renderPlot({
      plot_ggnet(
        df,
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
  })
}
networkplotApp <- function() {
  meta <- igraph::vertex_attr_names(example_network)
  ui <- shiny::fluidPage(
    networkplotInput("networkplot", meta),
    networkplotOutput("networkplot")
  )
  server <- function(input, output, session) {
    networkplotServer(
      "networkplot",
      ggnetwork::ggnetwork(example_network)
    )
  }
  shiny::shinyApp(ui, server)
}
# networkplotApp()

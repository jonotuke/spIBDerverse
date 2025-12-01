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
    shiny::downloadButton(
      shiny::NS(id, "down"),
      "Download plot"
    )
  )
}

networkplotServer <- function(id, network) {
  shiny::moduleServer(id, function(input, output, session) {
    ggnet <- shiny::reactive({
      set.seed(input$seed)
      ggnetwork::ggnetwork(network())
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
        choices = c("", igraph::vertex_attr_names(network()))
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "fill_id",
        choices = c("", igraph::vertex_attr_names(network()))
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "label_id",
        choices = c("", igraph::vertex_attr_names(network()))
      )
    })
    output$down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-network.pdf")
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          p(),
          width = 10,
          height = 10
        )
      }
    )
  })
}
networkplotApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    networkplotInput("networkplot", meta),
    networkplotOutput("networkplot"),
    shiny::verbatimTextOutput(outputId = "debug")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(
      network_input
    )
    networkplotServer(
      "networkplot",
      network
    )
    output$debug <- shiny::renderPrint({
      print(network())
      shiny::reactiveValuesToList(input)$`networkplot-solo_nodes`
    })
  }
  shiny::shinyApp(ui, server)
}
# networkplotApp(example_network_2) |> print()

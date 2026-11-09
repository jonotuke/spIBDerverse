# MODULE ----

spatialergmInput <- function(id, all_vars, cat_vars) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::selectInput(
      ns("lat"),
      label = "Choose latitude column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      ns("long"),
      label = "Choose longitude column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      ns("pred"),
      label = "Select predictor",
      choices = c("none", cat_vars),
      selected = "none"
    )
  )
}

spatialergmOutput <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::plotOutput(ns("plot")),
    shiny::verbatimTextOutput(ns("debug"))
  )
}

# Server: `r` is a reactiveValues object that must provide
#   r$network()      - the (possibly filtered) network to model
#   r$full_network() - the unfiltered network, used to populate the pickers
spatialergmServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    # Keep the column pickers in sync with the attributes of the network
    shiny::observeEvent(r$full_network(), {
      all_vars <- c("none", get_node_attributes(r$full_network()))
      cat_vars <- c("none", get_node_attributes(r$full_network(), type = "cat"))

      shiny::updateSelectInput(session, "lat", choices = all_vars)
      shiny::updateSelectInput(session, "long", choices = all_vars)
      shiny::updateSelectInput(session, "pred", choices = cat_vars)
    })

    ergm <- shiny::reactive({
      shiny::req(input$lat != "none", input$long != "none")

      fit_spatial_ergm(
        g = r$network(),
        lat = input$lat,
        long = input$long,
        pred = input$pred
      )
    })
    output$plot <- shiny::renderPlot({
      ergm() |> predict_spatial_ergm(N = 100) |> plot_spatial_ergm()
    })

    output$debug <- shiny::renderPrint({
      print("Hello world")
      ergm()
    })
  })
}

# STANDALONE ----
spatialergmApp <- function(network_input) {
  cat_vars <- get_node_attributes(network_input, type = "cat")
  all_vars <- get_node_attributes(network_input)

  r <- shiny::reactiveValues()
  r$network <- shiny::reactive(network_input)
  r$full_network <- shiny::reactive(network_input)

  ui <- shiny::fluidPage(
    spatialergmInput("ergm", all_vars, cat_vars),
    spatialergmOutput("ergm")
  )

  server <- function(input, output, session) {
    spatialergmServer("ergm", r = r)
  }

  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  spatialergmApp(example_network) |> print()
}

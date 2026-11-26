spatialergm_pal_choices <- function(continuous = FALSE) {
  plot_type <- if (continuous) "continuous" else "discrete"
  get_palettes() |>
    dplyr::filter(type %in% c(plot_type, "both")) |>
    dplyr::pull(name)
}

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
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      ns("pal"),
      label = "Choose palette",
      choices = spatialergm_pal_choices(),
      selected = "default"
    )
  )
}

spatialergmOutput <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::plotOutput(ns("plot"))
    # shiny::verbatimTextOutput(ns("debug"))
  )
}

spatialergmServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(r$full_network(), {
      all_vars <- c("none", get_node_attributes(r$full_network()))
      cat_vars <- c("none", get_node_attributes(r$full_network(), type = "cat"))

      shiny::updateSelectInput(session, "lat", choices = all_vars)
      shiny::updateSelectInput(session, "long", choices = all_vars)
      shiny::updateSelectInput(session, "pred", choices = all_vars)
    })

    pal_choices <- shiny::reactive({
      continuous <- input$pred != "none" &&
        is.numeric(igraph::vertex_attr(r$network(), input$pred))
      spatialergm_pal_choices(continuous)
    })

    shiny::observeEvent(pal_choices(), {
      selected <- if (isTRUE(input$pal %in% pal_choices())) {
        input$pal
      } else {
        "default"
      }
      shiny::updateSelectInput(
        session,
        "pal",
        choices = pal_choices(),
        selected = selected
      )
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

    # Separate from the plot so changing palette doesn't re-predict
    ergm_pred <- shiny::reactive({
      ergm() |> predict_spatial_ergm(N = 100)
    })

    output$plot <- shiny::renderPlot({
      # Wait until the palette picker has caught up with the predictor
      shiny::req(input$pal %in% pal_choices())

      ergm_pred() |> plot_spatial_ergm(pal = input$pal)
    })

    # output$debug <- shiny::renderPrint({
    #   print("Hello world")
    #   ergm()
    # })
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

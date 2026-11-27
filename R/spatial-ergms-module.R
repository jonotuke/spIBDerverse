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
    ),
    # Range is set from the fitted distances once a model is available
    shinyWidgets::numericRangeInput(
      ns("x_lim"),
      label = "Distance range (km)",
      value = c(0, 1),
      min = 0,
      step = 1
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

    # Largest distance in the predictions, rounded up to a whole km
    max_dist <- shiny::reactive({
      ceiling(max(ergm_pred()$dist))
    })

    # Reset the range input to the full distance range whenever a new model
    # is fitted. Freezing stops the plot drawing with the old values before
    # the browser sends back the updated ones.
    shiny::observeEvent(max_dist(), priority = 1, {
      shiny::freezeReactiveValue(input, "x_lim")
      shinyWidgets::updateNumericRangeInput(
        session,
        "x_lim",
        value = c(0, max_dist())
      )
    })

    # Debounced so the plot doesn't redraw on every keystroke
    x_lim_input <- shiny::reactive(input$x_lim) |> shiny::debounce(500)

    output$plot <- shiny::renderPlot({
      # Wait until the palette picker has caught up with the predictor
      shiny::req(input$pal %in% pal_choices(), x_lim_input())

      # Only zoom for a valid range that isn't the full range; otherwise
      # (blank box, lower >= upper, or full range) leave the axis as is
      x_lim <- x_lim_input()
      valid <- length(x_lim) == 2 && !anyNA(x_lim) && x_lim[1] < x_lim[2]
      if (!valid || isTRUE(all(x_lim == c(0, max_dist())))) {
        x_lim <- NULL
      }

      ergm_pred() |> plot_spatial_ergm(pal = input$pal, x_lim = x_lim)
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

if (sys.nframe() == 5) {
  spatialergmApp(example_network) |> print()
}

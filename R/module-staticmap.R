staticmapInput <- function(id, meta) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "lat"),
      label = "Choose latitude column",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "lon"),
      label = "Choose longitude column",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "col"),
      label = "Choose node colour column",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "shape"),
      label = "Choose node shape column",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::sliderInput(
      shiny::NS(id, "pt_size"),
      "Node size",
      min = 1,
      max = 10,
      value = 3
    ),
    shiny::sliderInput(
      shiny::NS(id, "zoom"),
      label = "Map resolution",
      min = 6,
      max = 15,
      value = 9,
      step = 1
    ),
    shiny::selectInput(
      shiny::NS(id, "maptype"),
      label = "Terrain type",
      choices = c(
        "stamen_terrain",
        "stamen_toner",
        "stamen_toner_lite",
        "stamen_watercolor",
        "stamen_terrain_background",
        "stamen_toner_background",
        "stamen_terrain_lines",
        "stamen_terrain_labels",
        "stamen_toner_lines",
        "stamen_toner_labels"
      ),
      selected = 1
    ),
    shiny::selectInput(
      shiny::NS(id, "theme"),
      label = "Theme type",
      choices = c(
        "minimal",
        "black white",
        "void"
      ),
      selected = 1
    ),
    shiny::textInput(
      shiny::NS(id, "key"),
      "Stadia API key",
      value = "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
    ),
    shiny::helpText(
      "The key would not normally be here - added for ease"
    ),
    shinyWidgets::numericRangeInput(
      shiny::NS(id, "lat_range"),
      "Latitude range",
      value = c(0, 180)
    ),
    shinyWidgets::numericRangeInput(
      shiny::NS(id, "lon_range"),
      "Longitude range",
      value = c(0, 180)
    )
  )
}

staticmapOutput <- function(id) {
  shiny::tagList(
    shiny::plotOutput({
      shiny::NS(id, "plot")
    }),
    shiny::actionButton(
      shiny::NS(id, "save"),
      "Set as export plot"
    )
  )
}

staticmapServer <- function(id, network, store) {
  shiny::moduleServer(id, function(input, output, session) {
    network_sf <- shiny::reactive({
      if (input$lat == "none" | input$lon == "none") {
        return(NULL)
      }
      convert_sf(network(), lat = input$lat, lon = input$lon) |>
        add_convert_bb_adj()
    })
    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      if (input$lat == "none" | input$lon == "none") {
        return(NULL)
      }
      plot_static_map(
        network_sf(),
        zoom = input$zoom,
        key = input$key,
        fill_col = input$col,
        shape_col = input$shape,
        maptype = input$maptype,
        pt_size = input$pt_size,
        lat_range = input$lat_range,
        lon_range = input$lon_range,
        theme = input$theme
      )
    })
    update_range <- function(id, type = "lat") {
      shinyWidgets::updateNumericRangeInput(
        session,
        id,
        value = round(get_lat_range(network_sf(), type = type), 2)
      )
    }
    shiny::observeEvent(network_sf(), {
      update_range("lat_range")
    })
    shiny::observeEvent(network_sf(), {
      update_range("lon_range", "lon")
    })
    shiny::observeEvent(input$save, {
      store$export <- shiny::reactive(
        p()
      )
    })
  })
}

staticmapApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)

  ui <- shiny::fluidPage(
    title = "Static map",
    staticmapInput("staticmap", meta),
    staticmapOutput("staticmap")
  )
  server <- function(input, output, session) {
    staticmapServer("staticmap", network_input)
  }
  shiny::shinyApp(ui, server)
}

staticmapInput <- function(id, all_vars, cat_vars, edge_vars) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "lat"),
      label = "Choose latitude column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "lon"),
      label = "Choose longitude column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::sliderInput(
      shiny::NS(id, "jitter"),
      label = "Add jitter to nodes",
      min = 0,
      max = 0.05,
      step = 0.01,
      value = 0
    ),
    network_ui(id, all_vars, cat_vars, edge_vars),
    shiny::sliderInput(
      shiny::NS(id, "zoom"),
      label = "Map resolution",
      min = 0,
      max = 15,
      value = 5,
      step = 1
    ) |>
      bslib::tooltip(
        "The level of resolution of the background map details. Higher values make the map more detailed, but take longer to download. We recommend leaving this value low while deciding on the ranges for the latitude and longitude, or the terrain type."
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
    ) |>
      bslib::popover(
        "The type of map that is used in the background."
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
    ) |>
      bslib::popover(
        "The plotting theme for the map. Minimal allows you to see the latitude and longitude values, black white is similar but removes the grey background from the legend, and video removes all axis labels and latitude and longitude values."
      ),
    shiny::textInput(
      shiny::NS(id, "key"),
      "Stadia API key",
      # value = "",
      value = "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
    ) |>
      bslib::popover(
        "This key is required to be able to download the map background. See this website for simple instructions on setting this up (https://docs.stadiamaps.com/authentication/#api-keys)."
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

staticmapServer <- function(id, network, r) {
  shiny::moduleServer(id, function(input, output, session) {
    network_sf <- shiny::reactive({
      if (input$lat == "none" | input$lon == "none") {
        return(NULL)
      }
      convert_sf(
        r$network(),
        lat = input$lat,
        lon = input$lon,
        jitter = input$jitter
      )
    })
    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      if (input$lat == "none" | input$lon == "none") {
        return(NULL)
      }
      plot_staticmap(
        sf = network_sf(),
        zoom = input$zoom,
        key = input$key,
        fill = input$fill,
        shape = input$shape,
        edge = input$edge,
        node_size = input$node_size,
        node_centrality = input$node_centrality,
        maptype = input$maptype,
        lat_range = input$lat_range,
        lon_range = input$lon_range,
        theme = input$theme,
        connected = input$connected,
        edge_legend = input$edge_legend,
        edge_trans = input$edge_trans,
        label = input$label,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        pal = input$pal
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
      r$export <- shiny::reactive(
        p()
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "lat",
        choices = c(
          "",
          get_node_attributes(r$full_network())
        )
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "lon",
        choices = c(
          "",
          get_node_attributes(r$full_network())
        )
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
  })
}

staticmapApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  cat_vars <- get_node_attributes(network_input, "cat")
  edge_vars <- igraph::edge_attr_names(network_input)

  r <- shiny::reactiveValues()
  r$network <- shiny::reactive({
    network_input
  })

  ui <- shiny::fluidPage(
    title = "Static map",
    staticmapInput(
      "staticmap",
      all_vars = all_vars,
      cat_vars = cat_vars,
      edge_vars = edge_vars
    ),
    staticmapOutput("staticmap")
  )
  server <- function(input, output, session) {
    staticmapServer("staticmap", r = r)
  }
  shiny::shinyApp(ui, server)
}

# staticmapApp(example_network_2) |> print()

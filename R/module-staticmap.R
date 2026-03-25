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
    shiny::selectInput(
      shiny::NS(id, "fill"),
      label = "Choose node fill column",
      choices = c("none", cat_vars),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "shape"),
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
    shiny::numericInput(
      shiny::NS(id, "node_size"),
      "Node size",
      min = 1,
      max = 20,
      value = 10,
      step = 1
    ),
    shiny::sliderInput(
      shiny::NS(id, "zoom"),
      label = "Map resolution",
      width = "100%",
      min = 0,
      max = 15,
      value = 5,
      step = 1
    ) |>
      prompter::add_prompt(
        message = "The level of resolution of the background map details.\n
Higher values make the map more detailed, but take longer to\n
download. We recommend leaving this value low while deciding on the\n
ranges for the latitude and longitude, or the terrain type.",
        type = "info",
        position = "right",
        rounded = TRUE
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
      selected = 1,
      width = "100%"
    ) |>
      prompter::add_prompt(
        message = "The type of map that is \n
used in the background.",
        type = "info",
        position = "right",
        rounded = TRUE
      ),
    shiny::selectInput(
      shiny::NS(id, "theme"),
      label = "Theme type",
      choices = c(
        "minimal",
        "black white",
        "void"
      ),
      selected = 1,
      width = "100%"
    ) |>
      prompter::add_prompt(
        message = "The plotting theme for the map. Minimal allows\n
you to see the latitude and longitude values, black white\n
is similar but removes the grey background from the legend,\n
and video removes all axis labels and latitude and longitude\n
values.
",
        type = "info",
        position = "right",
        rounded = TRUE
      ),
    shiny::textInput(
      shiny::NS(id, "key"),
      "Stadia API key",
      value = "",
      width = "100%"
      # value = "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
    ) |>
      prompter::add_prompt(
        message = "This key is required to be able to download the\n
        map background. See this website for simple instructions on\n
        setting this up\n
        (https://docs.stadiamaps.com/authentication/#api-keys).",
        type = "info",
        position = "right",
        rounded = TRUE
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
        fill_col = input$fill,
        shape_col = input$shape,
        edge_col = input$edge,
        maptype = input$maptype,
        pt_size = input$node_size,
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
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "lat",
        choices = c(
          "",
          get_node_attributes(network())
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "lon",
        choices = c(
          "",
          get_node_attributes(network())
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "shape",
        choices = c(
          "none",
          get_node_attributes(network(), "cat")
        )
      )
    })
    shiny::observeEvent(network(), {
      shiny::updateSelectInput(
        session,
        "fill",
        choices = c(
          "none",
          get_node_attributes(network(), "cat")
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
  })
}

staticmapApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  cat_vars <- get_node_attributes(network_input, "cat")
  edge_vars <- igraph::edge_attr_names(network_input)

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
    staticmapServer("staticmap", shiny::reactive(network_input))
  }
  shiny::shinyApp(ui, server)
}

# staticmapApp(example_network_2) |> print()

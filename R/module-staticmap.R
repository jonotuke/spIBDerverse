STADIA_MAPTYPES <- c(
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
)

# A usable numericRangeInput value: two non-missing, different numbers.
is_valid_range <- function(x) {
  length(x) == 2 && !anyNA(x) && diff(range(x)) > 0
}

# Keep the current selection if it is still one of the choices.
keep_selected <- function(current, choices) {
  if (isTRUE(current %in% choices)) current else choices[1]
}

# UI ----

staticmapInput <- function(id, all_vars, cat_vars, edge_vars, num_vars) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::sliderInput(
      ns("jitter"),
      label = "Add jitter to nodes",
      min = 0,
      max = 0.05,
      step = 0.01,
      value = 0
    ) |>
      hover_tooltip(
        "Moves each node by a small random amount (in degrees) so that
        nodes sharing the same location don't sit on top of each other."
      ),
    network_ui(id, all_vars, cat_vars, edge_vars, num_vars),
    shiny::sliderInput(
      ns("zoom"),
      label = "Map resolution",
      min = 0,
      max = 15,
      value = 5,
      step = 1
    ) |>
      hover_tooltip(
        "The level of resolution of the background map details.
        Higher values make the map more detailed, but take longer
        to download. We recommend leaving this value low while
        deciding on the ranges for the latitude and longitude, or
        the terrain type."
      ),
    shiny::selectInput(
      ns("maptype"),
      label = "Terrain type",
      choices = STADIA_MAPTYPES
    ) |>
      hover_tooltip("The type of map that is used in the background."),
    shiny::selectInput(
      ns("theme"),
      label = "Theme type",
      choices = c("minimal", "black white", "void")
    ) |>
      hover_tooltip(
        "The plotting theme for the map.
        Minimal allows you to see the latitude and longitude
        values, black white is similar but removes the grey
        background from the legend, and void removes all axis
        labels and latitude and longitude values."
      ),
    shiny::textInput(
      ns("key"),
      "Stadia API key",
      value = "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
    ) |>
      hover_tooltip(
        "This key is required to be able to download the map
        background. See this website for simple instructions on
        setting this up (https://docs.stadiamaps.com/authentication/#api-keys)."
      ),
    # Placeholder values: these are replaced with the network's extent as
    # soon as latitude and longitude attributes are chosen.
    shinyWidgets::numericRangeInput(
      ns("lat_range"),
      "Latitude range",
      value = c(-90, 90)
    ) |>
      hover_tooltip(
        "Set automatically to fit the network when the latitude and
        longitude attributes are chosen. Nodes outside the range are hidden."
      ),
    shinyWidgets::numericRangeInput(
      ns("lon_range"),
      "Longitude range",
      value = c(-180, 180)
    )
  )
}

staticmapOutput <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::plotOutput(ns("plot")),
    shiny::actionButton(ns("save"), "Set as export plot")
  )
}

# SERVER ----

staticmapServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    has_coords <- shiny::reactive({
      !is_none(input$lat) && !is_none(input$lon)
    })

    # SELECT CHOICES ----
    shiny::observeEvent(r$full_network(), {
      g <- r$full_network()
      coord_vars <- get_node_attributes(g, "num")
      choices <- list(
        lat = c("", coord_vars),
        lon = c("", coord_vars),
        fill = c("none", get_node_attributes(g)),
        shape = c("none", get_node_attributes(g, "cat")),
        edge = c("none", igraph::edge_attr_names(g))
      )
      for (nm in names(choices)) {
        shiny::updateSelectInput(
          session,
          nm,
          choices = choices[[nm]],
          selected = keep_selected(input[[nm]], choices[[nm]])
        )
      }
    })

    # LAT / LON RANGES ----
    # The extent of the current network for the chosen lat/lon attributes,
    # padded and rounded outwards the same way plot_staticmap() does by
    # default, so every node is inside the box.
    coord_range <- shiny::reactive({
      shiny::req(has_coords())
      rng <- tryCatch(
        node_coord_range(
          r$network(),
          lat = input$lat,
          long = input$lon,
          digits = 2
        ),
        error = function(e) NULL
      )
      shiny::req(rng)
    })

    # Reset the range inputs whenever the network or the lat/lon attributes
    # change. Freezing the inputs stops the plot from rendering (and
    # downloading tiles) with the old range while the new one is on its way.
    shiny::observeEvent(
      coord_range(),
      {
        rng <- coord_range()
        shiny::freezeReactiveValue(input, "lat_range")
        shiny::freezeReactiveValue(input, "lon_range")
        shinyWidgets::updateNumericRangeInput(
          session,
          "lat_range",
          value = rng$lat
        )
        shinyWidgets::updateNumericRangeInput(
          session,
          "lon_range",
          value = rng$lon
        )
      },
      priority = 1
    )

    # PLOT ----
    p <- shiny::reactive({
      shiny::validate(
        shiny::need(
          has_coords(),
          "Choose latitude and longitude attributes to draw the map."
        ),
        shiny::need(
          !is_none(input$key),
          "Enter a Stadia API key to download the map background."
        ),
        shiny::need(
          is_valid_range(input$lat_range) && is_valid_range(input$lon_range),
          "The latitude and longitude ranges each need two different values."
        )
      )

      plot_staticmap(
        g = r$network(),
        key = input$key,
        lat = input$lat,
        long = input$lon,
        zoom = input$zoom,
        maptype = input$maptype,
        lat_range = input$lat_range,
        lon_range = input$lon_range,
        jitter = input$jitter,
        theme = input$theme,
        # passed on to plot_network()
        connected = input$connected,
        edge = input$edge,
        edge_legend = input$edge_legend,
        edge_trans = input$edge_trans,
        label = input$label,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        fill = input$fill,
        shape = input$shape,
        node_size = input$node_size,
        node_centrality = input$node_centrality,
        pal = input$pal
      )
    })

    output$plot <- shiny::renderPlot(p())

    shiny::observeEvent(input$save, {
      r$export <- p
    })
  })
}

# APP ----

staticmapApp <- function(network_input) {
  r <- shiny::reactiveValues(
    network = shiny::reactive(network_input),
    full_network = shiny::reactive(network_input)
  )

  ui <- shiny::fluidPage(
    title = "Static map",
    staticmapInput(
      "staticmap",
      all_vars = get_node_attributes(network_input),
      cat_vars = get_node_attributes(network_input, "cat"),
      edge_vars = igraph::edge_attr_names(network_input),
      num_vars = get_node_attributes(network_input, "num", exc_central = FALSE)
    ),
    staticmapOutput("staticmap")
  )

  server <- function(input, output, session) {
    staticmapServer("staticmap", r = r)
  }

  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  staticmapApp(example_network_2) |> print()
}

networkplotInput <- function(id, cat_vars, all_vars, edge_vars, num_vars) {
  shiny::tagList(
    shiny::numericInput(
      shiny::NS(id, "seed"),
      label = "Set seed",
      value = 1000
    ) |>
      hover_tooltip(
        "Number to generate new network layout. Change this number to rearrange the nodes."
      ),
    network_ui(
      id,
      all_vars,
      cat_vars,
      edge_vars,
      num_vars
    )
  )
}

networkplotOutput <- function(id) {
  shiny::tagList(
    shiny::plotOutput(
      shiny::NS(id, "plot"),
      height = "800px"
    ),
    shiny::actionButton(
      shiny::NS(id, "save"),
      "Set as export plot"
    )
  )
}


networkplotServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    # Palette list only changes when ggsci does, so compute once
    palettes <- get_palettes()

    # "continuous" for numeric node attributes, "discrete" otherwise,
    # NA when nothing is selected
    attr_type <- function(var) {
      net <- r$full_network()
      if (is.null(net) || is.null(var) || var == "none") {
        return(NA_character_)
      }
      x <- igraph::vertex_attr(net, var)
      if (is.numeric(x)) "continuous" else "discrete"
    }

    pal_choices <- function(type) {
      if (is.na(type)) {
        return("default")
      }
      c(
        "default",
        palettes |>
          dplyr::filter(type == !!type) |>
          dplyr::pull(name) |>
          sort()
      )
    }

    # Link a column input to its palette input. Returns the type reactive
    # so it can be used elsewhere (e.g. passed to plot_network)
    link_palette <- function(var_id, pal_id) {
      type <- shiny::reactive(attr_type(input[[var_id]]))

      shiny::observeEvent(type(), {
        choices <- pal_choices(type())
        current <- input[[pal_id]]
        selected <- if (isTRUE(current %in% choices)) current else "default"
        shiny::updateSelectInput(
          session,
          pal_id,
          choices = choices,
          selected = selected
        )
      })

      type
    }

    fill_type <- link_palette("fill", "fill_pal")
    col_type <- link_palette("outline_col", "col_pal")

    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      if (is.null(r$network())) {
        return(NULL)
      }
      plot_network(
        r$network(),
        seed = input$seed,
        layout = input$layout,
        lat = input$lat,
        long = input$lon,
        connected = input$connected,
        edge = input$edge,
        node_size = input$node_size,
        edge_legend = input$edge_legend,
        edge_trans = input$edge_trans,
        label = input$label,
        label_filter = input$label_filter,
        label_size = input$label_size,
        label_inc = input$label_inc,
        label_exc = input$label_exc,
        label_col = input$label_col,
        fill = input$fill,
        shape = input$shape,
        size = input$size,
        fill_pal = input$fill_pal,
        outline_col = input$outline_col,
        col_pal = input$col_pal,
        outline_width = input$outline_width,
        alpha = input$alpha
      )
    })
    shiny::observeEvent(r$full_network(), {
      net <- r$full_network()
      all_vars <- c("none", get_node_attributes(net))

      shiny::updateSelectInput(
        session,
        "shape",
        choices = c("none", get_node_attributes(net, "cat"))
      )
      shiny::updateSelectInput(
        session,
        "size",
        choices = c(
          "none",
          get_node_attributes(net, "num", exc_central = FALSE)
        )
      )
      shiny::updateSelectInput(
        session,
        "alpha",
        choices = c(
          "none",
          get_node_attributes(net, "num", exc_central = FALSE)
        )
      )
      shiny::updateSelectInput(
        session,
        "edge",
        choices = c("none", igraph::edge_attr_names(net))
      )
      for (id in c(
        "fill",
        "outline_col",
        "label",
        "label_filter",
        "lat",
        "lon"
      )) {
        shiny::updateSelectInput(session, id, choices = all_vars)
      }
    })
    shiny::observeEvent(input$save, {
      r$export <- shiny::reactive(
        p()
      )
    })
  })
}

networkplotApp <- function(network_input) {
  cat_vars <- get_node_attributes(network_input, "cat")
  all_vars <- get_node_attributes(network_input)
  edge_vars <- igraph::edge_attr_names(network_input)
  num_vars <- get_node_attributes(network_input, "num", exc_central = FALSE)

  r <- shiny::reactiveValues()
  r$export <- shiny::reactive({
    plot_default_image()
  })
  r$network <- shiny::reactive(
    network_input
  )
  r$full_network <- shiny::reactive(
    network_input
  )

  ui <- shiny::fluidPage(
    theme = bslib::bs_theme(version = 5),
    title = "Network plot",
    networkplotInput(
      "networkplot",
      cat_vars = cat_vars,
      all_vars = all_vars,
      edge_vars = edge_vars,
      num_vars = num_vars
    ),
    networkplotOutput("networkplot"),
    shiny::plotOutput("export")
  )

  server <- function(input, output, session) {
    networkplotServer(
      "networkplot",
      r = r
    )

    exportplotServer(
      "exportplot",
      r = r
    )

    output$export <- shiny::renderPlot({
      r$export()
    })
  }
  shiny::shinyApp(ui, server)
}
if (sys.nframe() == 5) {
  networkplotApp(example_network) |> print()
}

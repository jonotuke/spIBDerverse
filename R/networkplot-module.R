keep_selected <- function(current, choices) {
  if (isTRUE(current %in% choices)) current else unname(choices[1])
}

label_choices <- function(x) {
  lookup <- internal_df()
  labels <- lookup$full_name[match(x, lookup$name)]
  labels <- ifelse(is.na(labels), x, labels)
  existing <- names(x)
  if (!is.null(existing)) {
    keep <- !is.na(existing) & nzchar(existing)
    labels[keep] <- existing[keep]
  }
  stats::setNames(x, labels)
}

network_ui_server <- function(input, session, r, choices = NULL) {
  palettes <- get_palettes()

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

  link_palette <- function(var_id, pal_id) {
    type <- shiny::reactive(attr_type(input[[var_id]]))

    shiny::observeEvent(type(), {
      pal <- pal_choices(type())
      shiny::updateSelectInput(
        session,
        pal_id,
        choices = pal,
        selected = keep_selected(input[[pal_id]], pal)
      )
    })

    type
  }

  # Attribute choices for a new network
  shiny::observeEvent(list(r$full_network(), input$internals), {
    net <- r$full_network()
    shiny::req(net)
    all_vars <- c(
      "none",
      get_node_attributes(net, inc_internals = input$internals)
    )
    num_vars <- c(
      "none",
      get_node_attributes(net, "num", inc_internals = input$internals)
    )
    cat_vars <- c(
      "none",
      get_node_attributes(net, "cat", inc_internals = input$internals)
    )
    label_vars <- c(
      "none",
      get_node_attributes(
        net,
        "all",
        inc_internals = input$internals,
        trim_levels = FALSE
      )
    )

    new_choices <- list(
      fill = all_vars,
      outline_col = all_vars,
      label = label_vars,
      label_filter = label_vars,
      lat = all_vars,
      lon = all_vars,
      shape = cat_vars,
      size = num_vars,
      alpha = num_vars,
      edge = c("none", igraph::edge_attr_names(net))
    )
    if (is.function(choices)) {
      new_choices <- utils::modifyList(new_choices, choices(net))
    }

    new_choices <- lapply(new_choices, pretty_choices)

    for (nm in names(new_choices)) {
      shiny::updateSelectInput(
        session,
        nm,
        choices = new_choices[[nm]],
        selected = keep_selected(input[[nm]], new_choices[[nm]])
      )
    }
  })

  invisible(list(
    fill_type = link_palette("fill", "fill_pal"),
    col_type = link_palette("outline_col", "col_pal")
  ))
}

network_plot_args <- function(input) {
  list(
    lat = input$lat,
    long = input$lon,
    connected = input$connected,
    edge = input$edge,
    edge_legend = input$edge_legend,
    edge_trans = input$edge_trans,
    label = input$label,
    label_inc = input$label_inc,
    label_exc = input$label_exc,
    label_col = input$label_col,
    fill = input$fill,
    shape = input$shape,
    size = input$size,
    node_size = input$node_size,
    fill_pal = input$fill_pal,
    outline_col = input$outline_col,
    col_pal = input$col_pal,
    outline_width = input$outline_width,
    alpha = input$alpha
  )
}

network_ui <- function(
  id,
  all_vars,
  cat_vars,
  edge_vars,
  num_vars,
  label_vars,
  first_panel = c("Nodes", "Location"),
  open = FALSE
) {
  ns <- shiny::NS(id)
  first_panel <- match.arg(first_panel)

  panels <- list(
    # NODES ----
    Nodes = bslib::accordion_panel(
      "Nodes",
      icon = shiny::icon("circle"),
      shiny::checkboxInput(
        ns("internals"),
        label = "Include centrality and clustering",
        value = TRUE
      ),
      shiny::selectInput(
        ns("layout"),
        label = "Choose node layout",
        choices = c(
          "Nicely" = "nicely",
          "Circle" = "circle",
          "Sphere" = "sphere",
          "Davidson-Harel" = "dh",
          "Fruchterman-Reingold" = "fr",
          "Kamada-Kawai" = "kk",
          "multidimensional scaling" = "mds"
        ),
        selected = "nicely"
      ),
      shiny::selectInput(
        ns("fill"),
        label = "Choose node fill column",
        choices = c("none", all_vars),
        selected = "none"
      ),
      shiny::selectInput(
        ns("fill_pal"),
        label = "Fill palette",
        choices = "default"
      ),
      shiny::selectInput(
        ns("outline_col"),
        label = "Choose node outline colour column",
        choices = c("none", all_vars),
        selected = "none"
      ),
      shiny::selectInput(
        ns("col_pal"),
        label = "Outline colour palette",
        choices = "default"
      ),
      shiny::selectInput(
        ns("shape"),
        label = "Choose node shape column",
        choices = c("none", cat_vars),
        selected = "none"
      ),
      shiny::selectInput(
        ns("size"),
        label = "Choose node size column",
        choices = c("none", num_vars),
        selected = "none"
      ),
      shiny::selectInput(
        ns("alpha"),
        label = "Choose node alpha",
        choices = c("none", num_vars),
        selected = "none"
      ),
      shiny::numericInput(
        ns("node_size"),
        "Node size",
        min = 1,
        max = 20,
        value = 10,
        step = 1
      ),
      shiny::numericInput(
        ns("outline_width"),
        "Node outline width",
        min = 1,
        max = 5,
        value = 1,
        step = 1
      ),
      shiny::radioButtons(
        ns("connected"),
        label = "Unconnected nodes",
        choices = c("Show", "Grey out", "Hide"),
        selected = "Show"
      ) |>
        hover_tooltip(
          "How to treat the unconnected nodes in the network plot."
        )
    ),

    # EDGES ----
    Edges = bslib::accordion_panel(
      "Edges",
      icon = shiny::icon("arrows-left-right"),
      shiny::selectInput(
        ns("edge"),
        label = "Choose edge column",
        choices = c("none", edge_vars),
        selected = "none"
      ),
      shiny::checkboxInput(
        ns("edge_legend"),
        label = "Add edge legend",
        value = TRUE
      ),
      shiny::selectInput(
        ns("edge_trans"),
        label = "Edge Transformation",
        choices = c("None" = "identity", "Log10" = "log10"),
        selected = "identity"
      ) |>
        hover_tooltip(
          "Method to scale the edge values and legend. Either \"None\" or a \"log10\" transformation."
        )
    ),

    # LABELS ----
    Labels = bslib::accordion_panel(
      "Labels",
      icon = shiny::icon("tag"),
      shiny::selectInput(
        ns("label"),
        label = "Label variable",
        choices = c("none", label_vars),
        selected = "none"
      ),
      shiny::numericInput(
        ns("label_size"),
        "Label size",
        min = 1,
        max = 20,
        value = 4
      ),
      shiny::radioButtons(
        ns("label_col"),
        label = "Label colour",
        choices = c("black", "white"),
        selected = "black"
      ),
      shiny::selectInput(
        ns("label_filter"),
        label = "Variable to filter labels on",
        choices = c("none", all_vars),
        selected = "none"
      ),
      shiny::textInput(ns("label_inc"), "Labels to include"),
      shiny::textInput(ns("label_exc"), "Labels to exclude")
    ),

    # LOCATION ----
    Location = bslib::accordion_panel(
      "Location",
      icon = shiny::icon("location-dot"),
      shiny::selectInput(
        ns("lat"),
        label = "Choose latitude column",
        choices = c("none", all_vars),
        selected = "none"
      ),
      shiny::selectInput(
        ns("lon"),
        label = "Choose longitude column",
        choices = c("none", all_vars),
        selected = "none"
      )
    )
  )

  # Put the chosen panel first, keep the rest in their original order
  panel_order <- c(first_panel, setdiff(names(panels), first_panel))

  rlang::exec(
    bslib::accordion,
    !!!unname(panels[panel_order]),
    open = open,
    multiple = TRUE
  )
}

networkplotInput <- function(
  id,
  cat_vars,
  all_vars,
  edge_vars,
  num_vars,
  label_vars
) {
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
      num_vars,
      label_vars
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
    network_ui_server(input, session, r)

    output$plot <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      if (is.null(r$network())) {
        return(NULL)
      }
      rlang::exec(
        plot_network,
        r$network(),
        seed = input$seed,
        layout = input$layout,
        label_filter = input$label_filter,
        !!!network_plot_args(input)
      )
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
  num_vars <- get_node_attributes(network_input, "num")
  label_vars <- get_node_attributes(network_input, trim_levels = FALSE)

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
      num_vars = num_vars,
      label_vars = label_vars
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

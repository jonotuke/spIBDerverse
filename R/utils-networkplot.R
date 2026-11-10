# HELPERS ----
keep_selected <- function(current, choices) {
  if (isTRUE(current %in% choices)) current else unname(choices[1])
}

network_vars <- function(net, ...) {
  list(
    all_vars = get_node_attributes(net, ...),
    cat_vars = get_node_attributes(net, "cat", ...),
    edge_vars = igraph::edge_attr_names(net),
    num_vars = get_node_attributes(net, "num", ...),
    label_vars = get_node_attributes(net, "all", trim_levels = FALSE, ...)
  )
}

# Settings shared by plot_network() and plot_staticmap().
network_plot_args <- function(input) {
  list(
    lat = input$lat,
    long = input$lon,
    connected = input$connected,
    edge = input$edge,
    edge_legend = input$edge_legend,
    edge_trans = input$edge_trans,
    label = input$label,
    label_size = input$label_size,
    label_filter = input$label_filter,
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

# UI ----
var_select <- function(id, label, vars) {
  shiny::selectInput(
    id,
    label = label,
    choices = c("none", vars),
    selected = "none"
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
  open = FALSE,
  show_layout = TRUE
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
      # Not needed when the nodes are placed by lat/lon (static map)
      if (show_layout) {
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
        )
      },
      shiny::hr(),
      var_select(ns("fill"), "Choose node fill column", all_vars),
      shiny::selectInput(
        ns("fill_pal"),
        label = "Fill palette",
        choices = "default"
      ),
      shiny::hr(),
      var_select(
        ns("outline_col"),
        "Choose node outline colour column",
        all_vars
      ),
      shiny::selectInput(
        ns("col_pal"),
        label = "Outline colour palette",
        choices = "default"
      ),
      shiny::numericInput(
        ns("outline_width"),
        "Node outline width",
        min = 1,
        max = 5,
        value = 1,
        step = 1
      ),
      shiny::hr(),
      var_select(ns("shape"), "Choose node shape column", cat_vars),
      shiny::hr(),
      var_select(ns("size"), "Choose node size column", num_vars),
      shiny::numericInput(
        ns("node_size"),
        "Node size",
        min = 1,
        max = 20,
        value = 10,
        step = 1
      ),
      shiny::hr(),
      var_select(ns("alpha"), "Choose node alpha", num_vars),
      shiny::hr(),
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
      var_select(ns("edge"), "Choose edge column", edge_vars),
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
      var_select(ns("label"), "Label variable", label_vars),
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
      var_select(
        ns("label_filter"),
        "Variable to filter labels on",
        label_vars
      ),
      shiny::textInput(ns("label_inc"), "Labels to include"),
      shiny::textInput(ns("label_exc"), "Labels to exclude")
    ),

    # LOCATION ----
    Location = bslib::accordion_panel(
      "Location",
      icon = shiny::icon("location-dot"),
      var_select(ns("lat"), "Choose latitude column", all_vars),
      var_select(ns("lon"), "Choose longitude column", all_vars)
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

# SERVER ----

# Keeps the network_ui() choices in sync with the current network, and the
# palette choices in sync with the type of the chosen fill / outline column.
# `choices` is an optional function of the network returning a named list of
# choices that override the defaults (see staticmapServer()).
network_ui_server <- function(input, session, r, choices = NULL) {
  palettes <- get_palettes()

  attr_type <- function(var) {
    net <- r$full_network()
    if (is.null(net) || is.null(var) || var == "none") {
      return(NA_character_)
    }
    if (is.numeric(igraph::vertex_attr(net, var))) "continuous" else "discrete"
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

  update_choices <- function(id, choices) {
    shiny::updateSelectInput(
      session,
      id,
      choices = choices,
      selected = keep_selected(input[[id]], choices)
    )
  }

  link_palette <- function(var_id, pal_id) {
    type <- shiny::reactive(attr_type(input[[var_id]]))
    shiny::observeEvent(type(), update_choices(pal_id, pal_choices(type())))
    type
  }

  # Attribute choices for a new network
  shiny::observeEvent(list(r$full_network(), input$internals), {
    net <- r$full_network()
    shiny::req(net)

    vars <- lapply(
      network_vars(net, inc_internals = input$internals),
      function(x) c("none", x)
    )

    new_choices <- list(
      fill = vars$all_vars,
      outline_col = vars$all_vars,
      label = vars$label_vars,
      label_filter = vars$label_vars,
      lat = vars$all_vars,
      lon = vars$all_vars,
      shape = vars$cat_vars,
      size = vars$num_vars,
      alpha = vars$num_vars,
      edge = vars$edge_vars
    )
    if (is.function(choices)) {
      new_choices <- utils::modifyList(new_choices, choices(net))
    }

    new_choices <- lapply(new_choices, pretty_choices)
    for (nm in names(new_choices)) {
      update_choices(nm, new_choices[[nm]])
    }
  })

  invisible(list(
    fill_type = link_palette("fill", "fill_pal"),
    col_type = link_palette("outline_col", "col_pal")
  ))
}

# STANDALONE APPS ----

# The shared reactive values used by the standalone test apps.
network_app_values <- function(net) {
  shiny::reactiveValues(
    network = shiny::reactive(net),
    full_network = shiny::reactive(net),
    export = shiny::reactive(plot_default_image())
  )
}

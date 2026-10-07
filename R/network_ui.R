network_ui <- function(id, all_vars, cat_vars, edge_vars, num_vars) {
  ns <- shiny::NS(id)

  bslib::accordion(
    open = "Nodes",
    multiple = TRUE,

    # NODES ----
    bslib::accordion_panel(
      "Nodes",
      icon = shiny::icon("circle"),
      shiny::selectInput(
        ns("fill"),
        label = "Choose node fill column",
        choices = c("none", all_vars),
        selected = "none"
      ),
      shiny::selectInput(
        ns("pal"),
        label = "Fill palette",
        choices = c("default", "ravenclaw", "colourblind")
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
      shiny::numericInput(
        ns("node_size"),
        "Node size",
        min = 1,
        max = 20,
        value = 10,
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
    bslib::accordion_panel(
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
    bslib::accordion_panel(
      "Labels",
      icon = shiny::icon("tag"),
      shiny::selectInput(
        ns("label"),
        label = "Label variable",
        choices = c("none", all_vars),
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
    bslib::accordion_panel(
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
}

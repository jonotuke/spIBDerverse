network_ui <- function(
  id,
  all_vars,
  cat_vars,
  edge_vars,
  num_vars,
  first_panel = c("Nodes", "Location")
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
        value = FALSE
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

  do.call(
    bslib::accordion,
    c(
      unname(panels[panel_order]),
      list(open = first_panel, multiple = TRUE)
    )
  )
}

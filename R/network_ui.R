network_ui <- function(id, all_vars, cat_vars, edge_vars, num_vars) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "fill"),
      label = "Choose node fill column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "shape"),
      label = "Choose node shape column",
      choices = c("none", cat_vars),
      selected = "none"
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "size"),
      label = "Choose node size column",
      choices = c("none", num_vars),
      selected = "none"
    ),
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
      shiny::NS(id, "edge"),
      label = "Choose edge column",
      choices = c("none", edge_vars),
      selected = "none"
    ),
    shiny::checkboxInput(
      shiny::NS(id, "edge_legend"),
      label = "Add edge legend",
      value = TRUE
    ),
    shiny::selectInput(
      shiny::NS(id, "edge_trans"),
      label = "Edge Transformation",
      choices = c(
        "None" = "identity",
        "Log10" = "log10"
      ),
      selected = "identity"
    ) |>
      hover_tooltip(
        "Method to scale the edge values and legend. Either \"None\" or a \"log10\"transformation."
      ),
    shiny::radioButtons(
      shiny::NS(id, "connected"),
      label = "Unconnected nodes",
      choices = c("Show", "Grey out", "Hide"),
      selected = "Show"
    ) |>
      hover_tooltip(
        "How to treat the unconnected nodes in the network plot."
      ),
    shiny::numericInput(
      shiny::NS(id, "node_size"),
      "Node size",
      min = 1,
      max = 20,
      value = 10,
      step = 1
    ),
    shiny::numericInput(
      shiny::NS(id, "label_size"),
      "Label size",
      min = 1,
      max = 20,
      value = 4
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "label"),
      label = "Label variable",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      inputId = shiny::NS(id, "label_filter"),
      label = "Variable to filter on",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::textInput(
      shiny::NS(id, "label_inc"),
      "Labels to include"
    ),
    shiny::textInput(
      shiny::NS(id, "label_exc"),
      "Labels to exclude"
    ),
    shiny::selectInput(
      shiny::NS(id, "pal"),
      label = "Fill palette",
      choices = c(
        "default",
        "ravenclaw",
        "colourblind"
      )
    )
  )
}

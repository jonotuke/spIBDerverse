network_ui <- function(id, all_vars, cat_vars, edge_vars) {
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
      selected = "identity",
      width = "100%"
    ) |>
      bslib::popover(
        "Method to scale the edge values and legend. Either \"None\" or a \"log10\"transformation."
      ),
    shiny::selectInput(
      shiny::NS(id, "node_centrality"),
      label = "Show node centrality",
      choices = c(
        "none",
        "degree",
        "betweenness",
        "closeness",
        "eigencentrality"
      ),
      selected = "none",
      width = "100%"
    ) |>
      bslib::popover(
        htmltools::HTML(
          "Degree: the number of other individuals an individual is connected to. High values indicate an individual has more relatives.
    <br><br>
      Closeness: the inverse of the sum of the shortest paths to all other nodes. Low values indicate that an individual is relatively closely related to all others.
    <br><br>
      Betweeness: how frequently an individual appears on the shortest path between all pairs of individuals. High values indicate that an individual is important to connecting the network.
    <br><br>
      Eigencentrality: a measure of \"prestige\" on the network. High values indicate that an individual is connected to many highly-connected individuals.",
        )
      ),
    shiny::radioButtons(
      shiny::NS(id, "connected"),
      label = "Unconnected nodes",
      choices = c("Show", "Grey out", "Hide"),
      selected = "Show"
    ) |>
      bslib::tooltip(
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
    shiny::textInput(
      shiny::NS(id, "label_inc"),
      "Labels to include"
    ),
    shiny::textInput(
      shiny::NS(id, "label_exc"),
      "Labels to exclude"
    )
  )
}

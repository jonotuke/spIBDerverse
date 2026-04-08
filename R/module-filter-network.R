networkFilterInput <- function(id, all_vars, edge_vars) {
  shiny::tagList(
    shiny::textInput(
      shiny::NS(id, "node_inc"),
      "Node names to include"
    ),
    shiny::textInput(
      shiny::NS(id, "node_exc"),
      "Node names to exclude"
    ),
    shiny::selectInput(
      shiny::NS(id, "node_column"),
      "Choose node attribute to filter on",
      choices = c("none", all_vars)
    ),
    shiny::uiOutput(
      shiny::NS(id, "node_cutoff")
    ),
    shiny::selectInput(
      shiny::NS(id, "edge_column"),
      "Choose edge attribute to filter on",
      choices = c("none", edge_vars)
    ),
    shiny::uiOutput(
      shiny::NS(id, "edge_cutoff")
    )
  )
}


make_node_cutoff_ui <- function(id, x, g) {
  if (x == "none") {
    return(NULL)
  }
  type <- class(igraph::vertex_attr(g, x))
  if (type == "numeric") {
    obs <- igraph::vertex_attr(g, x)
    shiny::tagList(
      shinyWidgets::numericRangeInput(
        shiny::NS(id, "node_cutoff"),
        label = stringr::str_glue("Enter the filter range for {x}"),
        value = c(
          min(obs, na.rm = TRUE),
          max(obs, na.rm = TRUE)
        )
      )
    )
  } else {
    levels <- sort(unique(igraph::vertex_attr(g, x)))
    shiny::checkboxGroupInput(
      inputId = shiny::NS(id, "node_cutoff"),
      label = stringr::str_glue("Select values of {x} to keep"),
      choices = levels,
      selected = levels[1]
    )
  }
}

make_edge_cutoff_ui <- function(id, x, g) {
  if (x == "none") {
    return(NULL)
  }
  type <- class(igraph::edge_attr(g, x))
  if (type == "numeric") {
    obs <- igraph::edge_attr(g, x)
    shiny::tagList(
      shinyWidgets::numericRangeInput(
        shiny::NS(id, "edge_cutoff"),
        label = stringr::str_glue("Enter the filter range for {x}"),
        value = c(
          min(obs, na.rm = TRUE),
          max(obs, na.rm = TRUE)
        )
      )
    )
  } else {
    levels <- sort(unique(igraph::edge_attr(g, x)))
    shiny::checkboxGroupInput(
      inputId = shiny::NS(id, "edge_cutoff"),
      label = stringr::str_glue("Select values of {x} to keep"),
      choices = levels,
      selected = levels[1]
    )
  }
}

networkFilterOutput <- function(id) {
  shiny::tagList(
    shiny::verbatimTextOutput({
      shiny::NS(id, "debug")
    })
  )
}

networkFilterServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print(input$node_cutoff)
      print(input$edge_cutoff)
      print(r$network())
    })
    r$network <- shiny::reactive({
      filter_network(
        r$full_network(),
        input$node_inc,
        input$node_exc,
        node_column = input$node_column,
        node_cutoff = input$node_cutoff,
        edge_column = input$edge_column,
        edge_cutoff = input$edge_cutoff
      )
    })
    output$node_cutoff <- shiny::renderUI({
      make_node_cutoff_ui(
        id,
        input$node_column,
        r$full_network()
      )
    })
    output$edge_cutoff <- shiny::renderUI({
      make_edge_cutoff_ui(
        id,
        input$edge_column,
        r$full_network()
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "node_column",
        choices = c(
          "none",
          get_node_attributes(r$full_network())
        )
      )
    })
  })
}
networkFilterApp <- function(network_input) {
  r <- shiny::reactiveValues()
  r$network <- shiny::reactive({
    network_input
  })
  r$full_network <- shiny::reactive({
    network_input
  })

  all_vars <- get_node_attributes(network_input)
  edge_vars <- igraph::edge_attr_names(network_input)

  ui <- shiny::fluidPage(
    networkFilterInput("networkFilter", all_vars, edge_vars),
    networkFilterOutput("networkFilter"),
    nodeOutput("node")
  )
  server <- function(input, output, session) {
    networkFilterServer("networkFilter", r = r)
    nodeServer("node", r = r)
  }
  shiny::shinyApp(ui, server)
}
# networkFilterApp() |> print()

networkFilterInput <- function(id, all_vars) {
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
      shiny::NS(id, "filter_column"),
      "Choose variable to filter on",
      choices = c("none", all_vars)
    ),
    shiny::uiOutput(
      shiny::NS(id, "filter_cutoff")
    )
  )
}


make_filter_cutoff_ui <- function(id, x, g) {
  if (x == "none") {
    return(NULL)
  }
  type <- class(igraph::vertex_attr(g, x))
  if (type == "numeric") {
    obs <- igraph::vertex_attr(g, x)
    shiny::tagList(
      shiny::numericInput(
        inputId = shiny::NS(id, "cutoff"),
        label = stringr::str_glue("Enter the value of {x} to filter on"),
        value = mean(obs, na.rm = TRUE),
        min = min(obs, na.rm = TRUE),
        max = max(obs, na.rm = TRUE)
      ),
      shiny::checkboxInput(
        inputId = shiny::NS(id, "is_less_than"),
        label = "Keep nodes that are less than than cutoff",
        value = TRUE
      )
    )
  } else {
    levels <- sort(unique(igraph::vertex_attr(g, x)))
    shiny::checkboxGroupInput(
      inputId = shiny::NS(id, "cutoff"),
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
      print(r$network())
    })
    r$network <- shiny::reactive({
      filter_network(
        r$full_network(),
        input$node_inc,
        input$node_exc,
        filter_column = input$filter_column,
        cutoff = input$cutoff,
        is_less_than = input$is_less_than
      )
    })
    output$filter_cutoff <- shiny::renderUI({
      make_filter_cutoff_ui(
        id,
        input$filter_column,
        r$full_network()
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "filter_column",
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

  ui <- shiny::fluidPage(
    networkFilterInput("networkFilter", all_vars),
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

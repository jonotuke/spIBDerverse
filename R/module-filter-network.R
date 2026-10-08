# UI ---
networkFilterInput <- function(id, all_vars, edge_vars) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::selectInput(
      ns("node_column"),
      "Choose node attribute to filter on",
      choices = c("none", all_vars)
    ),
    shiny::uiOutput(ns("node_cutoff")),
    shiny::selectInput(
      ns("edge_column"),
      "Choose edge attribute to filter on",
      choices = c("none", edge_vars)
    ),
    shiny::uiOutput(ns("edge_cutoff"))
  )
}

networkFilterOutput <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::verbatimTextOutput(ns("debug"))
  )
}


# HELPERS ----
#' Build the cutoff input for a node or edge attribute
#'
#' Numeric attributes get a range input spanning the observed values;
#' everything else gets a checkbox group of the distinct values.
#'
#' @param id Module id.
#' @param x Name of the attribute to filter on, or `"none"`.
#' @param g An igraph object.
#' @param what Either `"node"` or `"edge"`.
make_cutoff_ui <- function(id, x, g, what = c("node", "edge")) {
  what <- match.arg(what)

  if (is.null(x) || x == "none") {
    return(NULL)
  }

  ns <- shiny::NS(id)
  input_id <- ns(paste0(what, "_cutoff"))
  obs <- get_attr_values(g, x, what)

  if (is.numeric(obs)) {
    shinyWidgets::numericRangeInput(
      input_id,
      label = stringr::str_glue("Enter the filter range for {x}"),
      value = range(obs, na.rm = TRUE)
    )
  } else {
    levels <- sort(unique(obs))
    shiny::tagList(
      shiny::checkboxGroupInput(
        input_id,
        label = stringr::str_glue("Select values of {x} to keep"),
        choices = levels,
        selected = levels[1]
      ),
      shiny::div(
        style = "margin-top: -10px; margin-bottom: 15px;",
        shiny::actionButton(
          ns(paste0(what, "_select_all")),
          "Select all",
          class = "btn-sm"
        ),
        shiny::actionButton(
          ns(paste0(what, "_select_none")),
          "Select none",
          class = "btn-sm"
        )
      )
    )
  }
}

#' Get the observed values of a node or edge attribute
#'
#' @param g An igraph object.
#' @param x Name of the attribute.
#' @param what Either `"node"` or `"edge"`.
get_attr_values <- function(g, x, what = c("node", "edge")) {
  what <- match.arg(what)
  switch(
    what,
    node = igraph::vertex_attr(g, x),
    edge = igraph::edge_attr(g, x)
  )
}


# SERVER ----
networkFilterServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    r$network <- shiny::reactive({
      filter_network(
        r$full_network(),
        node_column = input$node_column,
        node_cutoff = input$node_cutoff,
        edge_column = input$edge_column,
        edge_cutoff = input$edge_cutoff
      )
    })

    output$node_cutoff <- shiny::renderUI({
      make_cutoff_ui(
        id,
        input$node_column,
        r$full_network(),
        what = "node"
      )
    })

    output$edge_cutoff <- shiny::renderUI({
      make_cutoff_ui(
        id,
        input$edge_column,
        r$full_network(),
        what = "edge"
      )
    })

    # Select all / select none for character (checkbox) attributes
    update_checkboxes <- function(what, column, select_all) {
      levels <- sort(
        unique(
          get_attr_values(r$full_network(), column, what)
        )
      )
      shiny::updateCheckboxGroupInput(
        session,
        paste0(what, "_cutoff"),
        selected = if (select_all) levels else character(0)
      )
    }

    shiny::observeEvent(input$node_select_all, {
      update_checkboxes("node", input$node_column, select_all = TRUE)
    })
    shiny::observeEvent(input$node_select_none, {
      update_checkboxes("node", input$node_column, select_all = FALSE)
    })
    shiny::observeEvent(input$edge_select_all, {
      update_checkboxes("edge", input$edge_column, select_all = TRUE)
    })
    shiny::observeEvent(input$edge_select_none, {
      update_checkboxes("edge", input$edge_column, select_all = FALSE)
    })

    # Keep the attribute choices in sync when the underlying network changes
    shiny::observeEvent(r$full_network(), {
      g <- r$full_network()
      shiny::updateSelectInput(
        session,
        "node_column",
        choices = c("none", get_node_attributes(g))
      )
      shiny::updateSelectInput(
        session,
        "edge_column",
        choices = c("none", igraph::edge_attr_names(g))
      )
    })

    output$debug <- shiny::renderPrint({
      print(input$node_cutoff)
      print(input$edge_cutoff)
      print(r$network())
    })
  })
}


# APP ----

networkFilterApp <- function(network_input) {
  r <- shiny::reactiveValues()
  r$network <- shiny::reactive(network_input)
  r$full_network <- shiny::reactive(network_input)

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

if (sys.nframe() == 5) {
  networkFilterApp(example_network) |> print()
}

# UI ---
networkFilterInput <- function(id, all_vars, edge_vars) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::actionButton(
      ns("run"),
      "Run filter",
      icon = shiny::icon("filter"),
      class = "btn-primary"
    ),
    shiny::selectizeInput(
      ns("node_columns"),
      "Choose node attributes to filter on",
      choices = all_vars,
      multiple = TRUE,
      options = list(
        placeholder = "None (keep all nodes)",
        plugins = list("remove_button")
      )
    ),
    shiny::uiOutput(ns("node_cutoffs")),
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
#' Input id for the cutoff control of one attribute
#'
#' Attribute names can contain characters that are not valid in input ids,
#' so they are sanitised here.
#'
#' @param x Attribute name.
#' @param what Either `"node"` or `"edge"`.
cutoff_input_id <- function(x, what = c("node", "edge")) {
  what <- match.arg(what)
  paste0(what, "_cutoff_", gsub("[^A-Za-z0-9_]", "_", x))
}

#' Build the cutoff input for a node or edge attribute
#'
#' Numeric range
#' Cat: levels
#'
#' @param id id
#' @param x attribute filter
#' @param g An igraph object.
#' @param what Either `"node"` or `"edge"`.
#' @param selected previous selected values
make_cutoff_ui <- function(
  id,
  x,
  g,
  what = c("node", "edge"),
  selected = NULL
) {
  what <- match.arg(what)

  if (is.null(x) || x == "none") {
    return(NULL)
  }

  ns <- shiny::NS(id)
  input_id <- ns(cutoff_input_id(x, what))
  obs <- get_attr_values(g, x, what)

  if (is.numeric(obs)) {
    shinyWidgets::numericRangeInput(
      input_id,
      label = stringr::str_glue("Enter the filter range for {x}"),
      value = if (is.null(selected)) {
        range(obs, na.rm = TRUE)
      } else {
        selected
      }
    )
  } else {
    levels <- sort(unique(as.character(obs)))
    select_js <- function(all) {
      sprintf(
        "Shiny.setInputValue('%s', {what: '%s', column: %s, all: %s}, {priority: 'event'});",
        ns("select_action"),
        what,
        jsonlite::toJSON(x, auto_unbox = TRUE),
        if (all) "true" else "false"
      )
    }
    shiny::tagList(
      shiny::checkboxGroupInput(
        input_id,
        label = stringr::str_glue("Select values of {x} to keep"),
        choices = levels,
        selected = if (is.null(selected)) levels else selected
      ),
      shiny::div(
        style = "margin-top: -10px; margin-bottom: 15px;",
        shiny::tags$button(
          type = "button",
          class = "btn btn-default btn-sm",
          onclick = select_js(TRUE),
          "Select all"
        ),
        shiny::tags$button(
          type = "button",
          class = "btn btn-default btn-sm",
          onclick = select_js(FALSE),
          "Select none"
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
    # Collect the current node filters as a named list: attribute -> cutoff
    collect_node_filters <- function(g) {
      cols <- intersect(input$node_columns, igraph::vertex_attr_names(g))
      filters <- lapply(cols, function(x) input[[cutoff_input_id(x, "node")]])
      names(filters) <- cols

      empty <- vapply(filters, is.null, logical(1))
      if (any(empty)) {
        shiny::showNotification(
          paste0(
            "No values selected for ",
            paste(cols[empty], collapse = ", "),
            "; that filter was skipped."
          ),
          type = "warning"
        )
      }
      filters[!empty]
    }

    # The filtered network only updates when Run is pressed (or when the
    # underlying network changes)
    r$network <- shiny::reactive({
      g <- r$full_network()

      edge_column <- input$edge_column
      if (
        is.null(edge_column) ||
          !edge_column %in% igraph::edge_attr_names(g)
      ) {
        edge_column <- "none"
      }
      edge_cutoff <- NULL
      if (edge_column != "none") {
        edge_cutoff <- input[[cutoff_input_id(edge_column, "edge")]]
        if (is.null(edge_cutoff)) {
          shiny::showNotification(
            paste0(
              "No values selected for ",
              edge_column,
              "; the edge filter was skipped."
            ),
            type = "warning"
          )
          edge_column <- "none"
        }
      }

      filter_network(
        g,
        node_filters = collect_node_filters(g),
        edge_column = edge_column,
        edge_cutoff = edge_cutoff
      )
    }) |>
      shiny::bindEvent(input$run, r$full_network(), ignoreNULL = FALSE)

    # One cutoff control per selected node attribute. Values already set
    # for an attribute are kept when other attributes are added or removed.
    output$node_cutoffs <- shiny::renderUI({
      g <- r$full_network()
      cols <- input$node_columns
      if (length(cols) == 0) {
        return(NULL)
      }
      shiny::tagList(
        lapply(cols, function(x) {
          shiny::wellPanel(
            style = "padding: 10px; margin-bottom: 10px;",
            make_cutoff_ui(
              id,
              x,
              g,
              what = "node",
              selected = shiny::isolate(input[[cutoff_input_id(x, "node")]])
            )
          )
        })
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

    # Select all / select none for character (checkbox) attributes.
    # Every button reports which attribute it belongs to via one input.
    shiny::observeEvent(input$select_action, {
      action <- input$select_action
      levels <- character(0)
      if (isTRUE(action$all)) {
        levels <- sort(unique(as.character(
          get_attr_values(r$full_network(), action$column, action$what)
        )))
      }
      shiny::updateCheckboxGroupInput(
        session,
        cutoff_input_id(action$column, action$what),
        selected = levels
      )
    })

    # Keep the attribute choices in sync when the underlying network changes
    shiny::observeEvent(r$full_network(), {
      g <- r$full_network()
      node_choices <- pretty_choices(
        get_node_attributes(g, inc_internals = TRUE)
      )
      shiny::updateSelectizeInput(
        session,
        "node_columns",
        choices = node_choices,
        selected = intersect(
          shiny::isolate(input$node_columns),
          unlist(node_choices)
        )
      )
      shiny::updateSelectInput(
        session,
        "edge_column",
        choices = c("none", igraph::edge_attr_names(g))
      )
    })

    output$debug <- shiny::renderPrint({
      for (x in input$node_columns) {
        cat(x, ": ", sep = "")
        print(input[[cutoff_input_id(x, "node")]])
      }
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
    shiny::tabsetPanel(
      id = "filter_tabs",
      shiny::tabPanel(
        title = "Edges",
        edgeOutput("edge")
      ),
      shiny::tabPanel(
        title = "Nodes",
        nodeOutput("node")
      )
    )
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

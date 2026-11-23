loaderInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fileInput(
      ns("edge_file"),
      "Upload an edge file"
    ),
    shiny::fileInput(
      ns("node_file"),
      "Upload a node file"
    ),
    shiny::numericInput(
      inputId = ns("crawl_length"),
      label = "SpIBDer-crawl length",
      min = 0,
      max = 20,
      value = 0,
      step = 1
    ),
    shiny::selectizeInput(
      ns("edge_columns"),
      "Choose edge attributes to define an edge",
      choices = NULL,
      multiple = TRUE,
      options = list(
        placeholder = "None",
        plugins = list("remove_button")
      )
    ),
    shiny::uiOutput(ns("edge_cutoffs"))
  )
}

loaderOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::verbatimTextOutput(
      shiny::NS(id, "debug")
    ),
    shiny::tableOutput(
      ns("tab")
    )
  )
}
loaderServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print("Full network")
      print(r$full_network())
      print("Edge cutoff inputs")
      cutoffs <- edge_cutoff_values()
      if (length(cutoffs) == 0) {
        print("None selected")
      } else {
        print(cutoffs)
      }
    })

    loader_data <- shiny::reactive({
      if (
        is.null(input$edge_file) |
          is.null(input$node_file)
      ) {
        return(NULL)
      }
      capture_conditions(
        loader(
          input$edge_file$datapath,
          input$node_file$datapath,
          crawl_length = input$crawl_length
        )
      )
    })

    shiny::observeEvent(loader_data(), {
      r$full_network <- shiny::reactive({
        loader_data()$network
      })
      shiny::updateSelectizeInput(
        session,
        "edge_columns",
        choices = igraph::edge_attr_names(loader_data()$network),
        selected = character(0)
      )
    })

    output$edge_cutoffs <- shiny::renderUI({
      network <- loader_data()$network
      cols <- input$edge_columns
      shiny::req(network, length(cols) > 0)

      inputs <- purrr::map(cols, function(col) {
        id <- edge_cutoff_id(col)
        values <- igraph::edge_attr(network, col)
        current <- shiny::isolate(input[[id]])

        if (is.numeric(values)) {
          rng <- suppressWarnings(range(values, na.rm = TRUE))
          if (!all(is.finite(rng))) {
            return(shiny::helpText(
              paste0("'", col, "' has no numeric values")
            ))
          }
          shinyWidgets::numericRangeInput(
            inputId = session$ns(id),
            label = paste("Range for", col),
            value = if (is.null(current)) rng else current,
            min = rng[1],
            max = rng[2]
          )
        } else {
          levels <- sort(
            unique(as.character(values[!is.na(values)]))
          )
          shiny::checkboxGroupInput(
            inputId = session$ns(id),
            label = paste("Values to keep for", col),
            choices = levels,
            selected = if (is.null(current)) levels else current
          )
        }
      })
      shiny::tagList(inputs)
    })

    # Current id, type and value of each cutoff input
    edge_cutoff_values <- shiny::reactive({
      cols <- input$edge_columns
      network <- loader_data()$network
      if (length(cols) == 0 || is.null(network)) {
        return(list())
      }
      purrr::map(purrr::set_names(cols), function(col) {
        id <- edge_cutoff_id(col)
        list(
          id = session$ns(id),
          type = if (is.numeric(igraph::edge_attr(network, col))) {
            "range"
          } else {
            "checkbox"
          },
          value = input[[id]]
        )
      })
    })

    output$tab <- shiny::renderTable({
      res <- loader_data()
      shiny::validate(
        shiny::need(res, "Please upload an edge and node file"),
        shiny::need(
          is.null(res$error),
          paste("Error:", res$error)
        ),
        shiny::need(
          length(res$warnings) == 0,
          paste("Warning:", res$warnings, collapse = "\n")
        ),
        shiny::need(
          length(res$messages) == 0,
          paste("Message:", res$messages, collapse = "\n")
        )
      )
      get_network_summary(res$network)
    })
  })
}

#' Build a valid input id for an edge attribute cutoff
#'
#' @param col edge attribute name
#'
#' @returns character id (not namespaced)
#' @noRd
edge_cutoff_id <- function(col) {
  paste0("cutoff_", make.names(col))
}

#' Evaluate an expression, capturing any error, warnings and messages
#'
#' @param expr expression to evaluate
#'
#' @returns list with network, error, warnings, messages
#' @noRd
capture_conditions <- function(expr) {
  error <- NULL
  warnings <- character()
  messages <- character()
  value <- withCallingHandlers(
    tryCatch(
      expr,
      error = function(e) {
        error <<- trimws(conditionMessage(e))
        NULL
      }
    ),
    warning = function(w) {
      warnings <<- c(warnings, trimws(conditionMessage(w)))
      invokeRestart("muffleWarning")
    },
    message = function(m) {
      messages <<- c(messages, trimws(conditionMessage(m)))
      invokeRestart("muffleMessage")
    }
  )
  list(
    network = value,
    error = error,
    warnings = unique(warnings),
    messages = unique(messages)
  )
}

loaderApp <- function() {
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    example_network
  })
  r$ibd_data <- shiny::reactive({
    NULL
  })
  ui <- shiny::fluidPage(
    loaderInput("ibdload"),
    loaderOutput("ibdload")
  )
  server <- function(input, output, session) {
    loaderServer("ibdload", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  loaderApp() |> print()
}

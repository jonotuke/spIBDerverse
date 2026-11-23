loaderInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fileInput(
      ns("edge_file"),
      "Upload an edge file"
    ),
    shiny::fileInput(
      ns("node_file"),
      "Upload a meta data file (nodes)"
    ),
    shiny::numericInput(
      inputId = ns("crawl_length"),
      label = "SpIBDer-crawl length",
      min = 0,
      max = 20,
      value = 0,
      step = 1
    )
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

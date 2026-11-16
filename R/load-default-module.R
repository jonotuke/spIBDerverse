loaddefaultInput <- function(id) {
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
    shiny::selectInput(
      ns("edge_var"),
      "Edge attribute",
      choices = c("None" = "none"),
      selected = "none"
    ),
    shiny::uiOutput(ns("edge_var_filter"))
  )
}

loaddefaultOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    # shiny::verbatimTextOutput(
    #   ns("debug")
    # ),
    shiny::tableOutput(
      ns("tab")
    )
  )
}

loaddefaultServer <- function(id, r, dev_files = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    edge_path <- shiny::reactive({
      if (!is.null(input$edge_file)) {
        input$edge_file$datapath
      } else {
        dev_files$edge
      }
    })

    node_path <- shiny::reactive({
      if (!is.null(input$node_file)) {
        input$node_file$datapath
      } else {
        dev_files$node
      }
    })

    default_full <- shiny::reactive({
      if (is.null(edge_path()) || is.null(node_path())) {
        return(NULL)
      }
      capture_conditions(
        load_default(
          node_file = node_path(),
          edge_file = edge_path()
        )
      )
    })

    r$default <- shiny::reactive({
      net <- default_full()$network
      if (
        is.null(net) ||
          identical(input$edge_var, "none") ||
          is.null(input$edge_var_range)
      ) {
        return(net)
      }
      filter_default_edges(net, input$edge_var, input$edge_var_range)
    })

    # output$debug <- shiny::renderPrint({
    #   print("default full")
    #   print(default_full()$network)
    #   print("edge_var_range")
    #   print(input$edge_var_range)
    #   print("r$default()")
    #   print(r$default())
    # })

    output$tab <- shiny::renderTable({
      res <- default_full()
      shiny::validate(
        shiny::need(res, "Please upload edge and node files"),
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
      net <- r$default()
      if (is.null(net)) {
        net <- res$network
      }
      get_network_summary(net)
    })

    output$edge_var_filter <- shiny::renderUI({
      shiny::req(input$edge_var != "none")
      x <- igraph::edge_attr(
        default_full()$network,
        input$edge_var
      )
      if (is.numeric(x)) {
        shinyWidgets::numericRangeInput(
          ns("edge_var_range"),
          label = stringr::str_glue("Range of {input$edge_var}"),
          value = range(x, na.rm = TRUE)
        )
      } else {
        shiny::checkboxGroupInput(
          ns("edge_var_range"),
          label = stringr::str_glue("Levels of {input$edge_var}"),
          choices = sort(unique(x)),
          selected = sort(unique(x))
        )
      }
    })

    shiny::observeEvent(default_full()$network, ignoreNULL = FALSE, {
      network <- default_full()$network
      attrs <- if (is.null(network)) {
        character(0)
      } else {
        igraph::edge_attr_names(network)
      }
      choices <- c("None" = "none", stats::setNames(attrs, attrs))
      selected <- if (isTRUE(input$edge_var %in% choices)) {
        input$edge_var
      } else {
        "none"
      }
      shiny::updateSelectInput(
        session,
        "edge_var",
        choices = choices,
        selected = selected
      )
    })
  })
}


loaddefaultApp <- function(dev_files = NULL) {
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    example_network
  })
  r$default_data <- shiny::reactive({
    NULL
  })
  ui <- shiny::fluidPage(
    loaddefaultInput("defaultload"),
    loaddefaultOutput("defaultload")
  )
  server <- function(input, output, session) {
    loaddefaultServer("defaultload", r = r, dev_files = dev_files)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  loaddefaultApp(
    dev_files = list(
      edge = "inst/extdata/load-default-data/default-edge.csv",
      node = "inst/extdata/load-default-data/default-node.csv"
    )
  ) |>
    print()
}

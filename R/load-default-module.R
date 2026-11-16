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
      ns("edge_attr"),
      "Edge attribute",
      choices = c("None" = "none"),
      selected = "none"
    ),
    shiny::uiOutput(ns("edge_attr_filter"))
  )
}

loaddefaultOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::verbatimTextOutput(
      ns("debug")
    ),
    shiny::tableOutput(
      ns("tab")
    )
  )
}

loaddefaultServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$debug <- shiny::renderPrint({
      print("default data")
      print(default_data()$network)
      print(r$default_data())
    })

    default_data <- shiny::reactive({
      if (
        is.null(input$edge_file) ||
          is.null(input$node_file)
      ) {
        return(NULL)
      }
      capture_conditions(
        load_default(
          node_file = input$node_file$datapath,
          edge_file = input$edge_file$datapath
        )
      )
    })

    # ---- Summary table ------------------------------------------------------

    output$tab <- shiny::renderTable({
      res <- default_data()
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
      get_network_summary(res$network)
    })
  })
}


loaddefaultApp <- function() {
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
    loaddefaultServer("defaultload", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  loaddefaultApp() |> print()
}

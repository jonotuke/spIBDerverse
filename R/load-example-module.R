loadexampleInput <- function(id) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "example_data"),
      label = "Example dataset",
      choices = c(
        "example_network",
        "example_network_2",
        "example_network_3",
        "example_network_4",
        "example_network_5",
        "example_network_6",
        "example_network_7"
      )
    )
  )
}
loadexampleOutput <- function(id) {
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
loadexampleServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print("Example data")
      print(example_data()$network)
    })
    example_data <- shiny::reactive({
      shiny::req(input$example_data)
      capture_conditions(
        load_example(example = input$example_data)
      )
    })

    r$example <- shiny::reactive({
      shiny::req(example_data()$network)
      example_data()$network
    })

    output$tab <- shiny::renderTable({
      res <- example_data()
      shiny::validate(
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


loadexampleApp <- function() {
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    example_network
  })
  r$example <- shiny::reactive({
    NULL
  })
  ui <- shiny::fluidPage(
    loadexampleInput("loadexample"),
    loadexampleOutput("loadexample")
  )
  server <- function(input, output, session) {
    loadexampleServer("loadexample", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  loadexampleApp() |> print()
}

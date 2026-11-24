#' data-wizard input
#' @noRd
dataWizardInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::radioButtons(
      ns("data_type"),
      "Type of data",
      choices = c(
        "Loader module" = "loader",
        "Load example data" = "example"
      )
    ),
    shiny::uiOutput(
      ns("input")
    )
  )
}
#' data-wizard output
#' @noRd
dataWizardOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    # shiny::verbatimTextOutput(ns("debug")),
    shiny::uiOutput(
      ns("output")
    )
  )
}

#' data-wizard server
#' @noRd
dataWizardServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- shiny::NS(id)
    loadexampleServer("example", r = r)
    loaderServer("loader", r = r)

    # output$debug <- shiny::renderPrint({
    #   show <- function(label, f) {
    #     cat("---", label, "---\n")
    #     res <- tryCatch(
    #       f(),
    #       shiny.silent.error = function(e) "<req() not satisfied>",
    #       error = function(e) paste("<error:", conditionMessage(e), ">")
    #     )
    #     print(res)
    #   }
    #   cat("Hello world\n")
    #   show("Full network", r$full_network)
    #   show("Example", r$example)
    #   show("Loader", r$loader)
    # })

    output$input <- shiny::renderUI({
      switch(
        input$data_type,
        example = loadexampleInput(ns("example")),
        loader = loaderInput(ns("loader"))
      )
    })

    output$output <- shiny::renderUI({
      switch(
        input$data_type,
        example = loadexampleOutput(ns("example")),
        loader = loaderOutput(ns("loader"))
      )
    })

    # shiny::observeEvent(input$data_type, {
    #   if (input$data_type == "example") {
    #     r$full_network <- shiny::reactive({
    #       r$example()
    #     })
    #   } else if (input$data_type == "loader") {
    #     r$full_network <- shiny::reactive({
    #       r$loader()
    #     })
    #   } else {
    #     return(NULL)
    #   }
    # })

    shiny::observe({
      net <- switch(
        input$data_type,
        example = r$example(),
        loader = r$loader()
      )
      shiny::req(net) # keep the current network until the new source has one
      r$full_network <- shiny::reactive(net)
    })

    output$tab <- shiny::renderTable({
      shiny::req(r$full_network())
      get_network_summary(r$full_network())
    })
  })
}
#' data-wizard app
#' @noRd
dataWizardApp <- function() {
  r <- shiny::reactiveValues()
  r$network <- shiny::reactive({
    example_network
  })
  r$full_network <- shiny::reactive({
    example_network
  })
  r$example <- shiny::reactive({
    NULL
  })
  r$loader <- shiny::reactive({
    NULL
  })
  ui <- shiny::fluidPage(
    dataWizardInput("dataWizard"),
    dataWizardOutput("dataWizard"),
  )
  server <- function(input, output, session) {
    dataWizardServer("dataWizard", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  dataWizardApp() |> print()
}

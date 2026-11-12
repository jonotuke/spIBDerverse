dataWizardInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::radioButtons(
      ns("data_type"),
      "Type of data",
      choices = c(
        "Load example data" = "example",
        "Load IBD data" = "ibd"
      )
    ),
    shiny::uiOutput(
      ns("input")
    )
  )
}

dataWizardOutput <- function(id) {
  shiny::tagList(
    shiny::tableOutput({
      shiny::NS(id, "tab")
    }),
    shiny::verbatimTextOutput(
      shiny::NS(id, "debug")
    )
  )
}


dataWizardServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- shiny::NS(id)
    loadexampleServer("example", r = r)
    loadibdServer("ibd", r = r)

    output$debug <- shiny::renderPrint({
      print("Hello world")
      print("Full network")
      print(r$full_network())
      print("Example")
      print(r$example())
      print("IBD")
      print(r$ibd_data())
    })

    output$input <- shiny::renderUI({
      switch(
        input$data_type,
        example = loadexampleInput(ns("example")),
        ibd = loadibdInput(ns("ibd"))
      )
    })

    shiny::observeEvent(input$data_type, {
      if (input$data_type == "example") {
        r$full_network <- shiny::reactive({
          r$example()
        })
      } else if (input$data_type == "ibd") {
        r$full_network <- shiny::reactive({
          r$ibd_data()
        })
      } else {
        return(NULL)
      }
    })

    output$tab <- shiny::renderTable({
      shiny::req(r$full_network())
      get_network_summary(r$full_network())
    })
  })
}

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
  r$ibd_data <- shiny::reactive({
    NULL
  })
  ui <- shiny::fluidPage(
    dataWizardInput("dataWizard"),
    dataWizardOutput("dataWizard"),
    nodeOutput("node")
  )
  server <- function(input, output, session) {
    dataWizardServer("dataWizard", r = r)
    nodeServer("node", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  dataWizardApp() |> print()
}

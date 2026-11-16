dataWizardInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::radioButtons(
      ns("data_type"),
      "Type of data",
      choices = c(
        "Load example data" = "example",
        "Load IBD data" = "ibd",
        "Load default data" = "default"
      )
    ),
    shiny::uiOutput(
      ns("input")
    )
  )
}

dataWizardOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    # shiny::verbatimTextOutput(ns("debug")),
    shiny::uiOutput(
      ns("output")
    )
  )
}


dataWizardServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- shiny::NS(id)
    loadexampleServer("example", r = r)
    loadibdServer("ibd", r = r)
    loaddefaultServer("default", r = r)

    output$debug <- shiny::renderPrint({
      print("Hello world")
      print("Full network")
      print(r$full_network())
      print("Example")
      print(r$example())
      print("IBD")
      print(r$ibd_data())
      print("Default")
      print(r$default())
    })

    output$input <- shiny::renderUI({
      switch(
        input$data_type,
        example = loadexampleInput(ns("example")),
        ibd = loadibdInput(ns("ibd")),
        default = loaddefaultInput(ns("default"))
      )
    })

    output$output <- shiny::renderUI({
      switch(
        input$data_type,
        example = loadexampleOutput(ns("example")),
        ibd = loadibdOutput(ns("ibd")),
        default = loaddefaultOutput(ns("default"))
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
      } else if (input$data_type == "default") {
        r$full_network <- shiny::reactive({
          r$default()
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
  r$default <- shiny::reactive({
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

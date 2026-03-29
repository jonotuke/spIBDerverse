dataWizardInput <- function(id) {
  shiny::tagList(
    shiny::radioButtons(
      shiny::NS(id, "data_type"),
      "Type of data",
      choices = c(
        "Load example data" = "example",
        "Upload IBD data" = "ibd",
        "Upload general network data" = "network"
      )
    ),
    shiny::uiOutput(
      shiny::NS(id, "data_ui")
    ),
    shiny::textInput(
      shiny::NS(id, "node_inc"),
      "Node names to include"
    ),
    shiny::textInput(
      shiny::NS(id, "node_exc"),
      "Node names to exclude"
    )
  )
}
dataWizardOutput <- function(id) {
  shiny::tagList(
    shiny::verbatimTextOutput(
      shiny::NS(id, "debug")
    ),
    DT::DTOutput(
      shiny::NS(id, "node_dt")
    )
  )
}
make_ui <- function(x, id) {
  if (is.null(x)) {
    ui <- NULL
  }
  if (x == "example") {
    ui <- shiny::tagList(
      shiny::helpText("Please choose an example dataset."),
      shiny::selectInput(
        shiny::NS(id, "example_data"),
        label = "Example dataset",
        choices = c(
          "example_network",
          "example_network_2",
          "example_network_3"
        )
      )
    )
  }
  if (x == "ibd") {
    ui <- shiny::tagList(
      shiny::helpText("Please upload your IBD and meta files"),
      shiny::fileInput(
        shiny::NS(id, "ibd_file"),
        "Upload an IBD file (edges)"
      ) |>
        bslib::tooltip(
          "Upload pairwise IBD file. Each line should have two individuals, and how related that pair is. Additional columns can include pairwise information (like geographic distance for example). The first column should be called \"iid1\" and the second column \"iid2\"."
        ),
      shiny::fileInput(
        shiny::NS(id, "meta_file"),
        "Upload a meta data file (nodes)"
      ) |>
        bslib::tooltip(
          "Upload your meta data for the individuals. This can include any meta data you might like to plot or test. The first column should be called \"iid\"."
        ),
      shiny::checkboxInput(
        shiny::NS(id, "filter"),
        "Filter edges to just nodes in metafile",
        value = TRUE
      ) |>
        bslib::tooltip(
          "Toggle this off to keep ALL IBD information. Will slow down analyses!"
        ),
      shiny::textInput(
        shiny::NS(id, "cutoffs"),
        label = "Please enter cutoffs with commas between",
        value = "0,2,1,0"
      ) |>
        bslib::popover(
          "This defines the definition of two individuals being \"connected\". A comma-separated description of the cut-off for the minimum number of blocks of IBD of length >=8cM, >=12cM, >=16cM and >=20cM."
        ),
      shiny::numericInput(
        shiny::NS(id, "frac_cutoff"),
        label = "Minimum Frac GP",
        value = 0.7
      ) |>
        bslib::popover(
          "Used for quality control. The fraction of genotype likelihoods that had posterior values of >=0.99, indicating high quality imputation. Recommended default is 0.7."
        )
    )
  }
  if (x == "network") {
    ui <- shiny::tagList(
      shiny::helpText("Please upload your edge and meta files"),
      shiny::fileInput(
        shiny::NS(id, "edge_file"),
        "Upload an edge file"
      ),
      shiny::fileInput(
        shiny::NS(id, "meta_file"),
        "Upload a meta data file (nodes)"
      ),
      shiny::checkboxInput(
        shiny::NS(id, "filter"),
        "Filter edges to just nodes in metafile",
        value = TRUE
      ) |>
        bslib::tooltip(
          "Toggle this off to keep ALL IBD information. Will slow down analyses!"
        )
    )
  }
  return(ui)
}

dataWizardServer <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print("Hello world")
      print(input$data_type)
    })
    output$data_ui <- shiny::renderUI({
      make_ui(input$data_type, id)
    })
    output$node_dt <- DT::renderDT({
      shinipsum::random_DT(nrow = 10, ncol = 5)
    })
  })
}

dataWizardApp <- function() {
  ui <- shiny::fluidPage(
    dataWizardInput("dataWizard"),
    dataWizardOutput("dataWizard")
  )
  server <- function(input, output, session) {
    dataWizardServer("dataWizard")
  }
  shiny::shinyApp(ui, server)
}
# dataWizardApp() |> print()

make_dataWizard_ui <- function(x, id, edge_vars) {
  if (is.null(x)) {
    ui <- NULL
  }
  if (x == "example") {
    ui <- shiny::tagList(
      shiny::selectInput(
        shiny::NS(id, "example_data"),
        label = "Example dataset",
        choices = c(
          "example_network",
          "example_network_2",
          "example_network_3",
          "example_network_4",
          "europe_network"
        )
      )
    )
  }
  if (x == "ibd") {
    ui <- shiny::tagList(
      shiny::fileInput(
        shiny::NS(id, "ibd_edge_file"),
        "Upload an IBD file (edges)"
      ) |>
        hover_tooltip(
          "Upload pairwise IBD file. 
          Each line should have two individuals, 
          and how related that pair is. 
          Additional columns can include pairwise information 
          (like geographic distance for example). 
          The first column should be called \"iid1\" and 
          the second column \"iid2\"."
        ),
      shiny::uiOutput(
        shiny::NS(id, "ibd_status")
      ),
      shiny::fileInput(
        shiny::NS(id, "ibd_meta_file"),
        "Upload a meta data file (nodes)"
      ) |>
        hover_tooltip(
          "Upload your meta data for the individuals. 
          This can include any meta data you might like to 
          plot or test. The first column should be called \"iid\"."
        ),
      shiny::uiOutput(
        shiny::NS(id, "meta_status")
      ),
      shiny::checkboxInput(
        shiny::NS(id, "ibd_filter"),
        "Filter edges to just nodes in metafile",
        value = TRUE
      ) |>
        hover_tooltip(
          "Toggle this off to keep ALL IBD information. Will slow down analyses!"
        ),
      shiny::textInput(
        shiny::NS(id, "ibd_cutoffs"),
        label = "Please enter cutoffs with commas between",
        value = "0,2,1,0"
      ) |>
        hover_tooltip(
          "This defines the definition of two individuals being \"connected\". A comma-separated description of the cut-off for the minimum number of blocks of IBD of length >=8cM, >=12cM, >=16cM and >=20cM."
        ),
      shiny::numericInput(
        shiny::NS(id, "ibd_frac_cutoff"),
        label = "Minimum Frac GP",
        value = 0.7
      ) |>
        hover_tooltip(
          "Used for quality control. The fraction of genotype likelihoods that had posterior values of >=0.99, indicating high quality imputation. Recommended default is 0.7."
        ),
      shiny::uiOutput(
        shiny::NS(id, "network_status")
      )
    )
  }
  if (x == "distance") {
    ui <- shiny::tagList(
      shiny::fileInput(
        shiny::NS(id, "dist_edge_file"),
        "Upload an edge file"
      ),
      shiny::fileInput(
        shiny::NS(id, "dist_meta_file"),
        "Upload a meta data file (nodes)"
      )
    )
  }
  if (x == "rds") {
    ui <- shiny::tagList(
      shiny::fileInput(
        shiny::NS(id, "rds_file"),
        "Upload a previous saved network"
      )
    )
  }
  return(ui)
}

#' dataWizardInput
#'
#' @param id shiny id
#'
#' @returns input UI for data Wizard
#'
#' @importFrom rlang %||%
#' @export
dataWizardInput <- function(id) {
  shiny::tagList(
    shiny::radioButtons(
      shiny::NS(id, "data_type"),
      "Type of data",
      choices = c(
        "Load example data" = "example",
        "Load IBD data" = "ibd",
        "Load distance data" = "distance",
        "Load previous network" = "rds"
      )
    ),
    shiny::uiOutput(
      shiny::NS(id, "data_ui"),
    ),
    shiny::textInput(
      shiny::NS(id, "filename"),
      label = "Filename",
      value = stringr::str_glue("{lubridate::today()}-network.rds")
    ),
    shiny::downloadButton(
      shiny::NS(id, "save"),
      "Save network"
    )
  )
}
dataWizardOutput <- function(id) {
  shiny::tagList(
    shiny::tableOutput({
      shiny::NS(id, "tab")
    })
    # shiny::verbatimTextOutput(
    #   shiny::NS(id, "debug")
    # )
  )
}


dataWizardServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print("Example data")
      print(example_data())
      print("IBD data")
      print(ibd_data())
      print("RDS data")
      print(rds_data())
      print("DIST data")
      print(dist_data())
      print("Full network")
      print(r$full_network())
    })
    output$data_ui <- shiny::renderUI({
      make_dataWizard_ui(input$data_type, id)
    })
    example_data <- shiny::reactive({
      load_example(input$example_data)
    })
    ibd_data <- shiny::reactive({
      if (
        is.null(input$ibd_edge_file) |
          is.null(input$ibd_meta_file)
      ) {
        return(NULL)
      }
      shiny::req(input$ibd_edge_file)
      shiny::req(input$ibd_meta_file)
      load_ibd_network(
        input$ibd_edge_file$datapath,
        input$ibd_meta_file$datapath,
        ibd_co = ibd_cutoffs(),
        frac_co = input$ibd_frac_cutoff,
        filter_on_meta = input$ibd_filter
      )
    })
    rds_data <- shiny::reactive({
      if (is.null(input$rds_file)) {
        return(NULL)
      }
      shiny::req(input$rds_file)
      load_rds_data(
        input$rds_file$datapath
      )
    })
    dist_data <- shiny::reactive({
      if (
        is.null(input$dist_edge_file) |
          is.null(input$dist_meta_file)
      ) {
        return(NULL)
      }
      shiny::req(input$dist_edge_file)
      shiny::req(input$dist_meta_file)
      load_dist_network(
        node_file = input$dist_meta_file$datapath,
        edge_file = input$dist_edge_file$datapath
      )
    })
    ibd_cutoffs <- shiny::reactive({
      stringr::str_split(input$ibd_cutoffs, ",") |>
        purrr::pluck(1) |>
        purrr::map_dbl(as.numeric)
    })
    shiny::observeEvent(input$data_type, {
      if (input$data_type == "example") {
        r$full_network <- shiny::reactive({
          example_data()
        })
      } else if (input$data_type == "ibd") {
        r$full_network <- shiny::reactive({
          ibd_data()
        })
      } else if (input$data_type == "distance") {
        r$full_network <- shiny::reactive({
          dist_data()
        })
      } else if (input$data_type == "rds") {
        r$full_network <- shiny::reactive({
          rds_data()
        })
      } else {
        return(NULL)
      }
    })
    output$save <- shiny::downloadHandler(
      filename = function() {
        input$filename
      },
      content = function(file) {
        readr::write_rds(x = r$network(), file = file)
      }
    )
    output$ibd_status <- shiny::renderUI({
      shiny::req(input$ibd_edge_file)
      msg <- check_ibd_file(input$ibd_edge_file$datapath)
      get_status(msg)
    })
    output$meta_status <- shiny::renderUI({
      shiny::req(input$ibd_meta_file)
      msg <- check_meta_file(input$ibd_meta_file$datapath)
      get_status(msg)
    })
    output$network_status <- shiny::renderUI({
      shiny::req(input$ibd_meta_file)
      shiny::req(input$ibd_edge_file)
      msg <- check_ibd_files(
        input$ibd_edge_file$datapath,
        input$ibd_meta_file$datapath
      )
      get_status(msg)
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
  ui <- shiny::fluidPage(
    dataWizardInput("dataWizard"),
    dataWizardOutput("dataWizard"),
    nodeOutput("node")
  )
  server <- function(input, output, session) {
    dataWizardServer("dataWizard", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  dataWizardApp() |> print()
}

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
    shiny::uiOutput({
      shiny::NS(id, "report")
    }),
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
    output$report <- shiny::renderUI({
      conditional_section <- switch(
        input$data_type,
        example = list(
          header = "Example network",
          color = "#E6F1FB",
          border = "#378ADD",
          data = stringr::str_glue(
            "Data: {input$example_data}"
          )
        ),
        ibd = list(
          header = "IBD data network",
          color = "#FAEEDA",
          border = "#EF9F27",
          data = htmltools::HTML(
            stringr::str_glue(
              "Files: 
              <br>
                ibd - {input$ibd_edge_file$name %||% 'not uploaded'}
              <br>
                meta - {input$ibd_meta_file$name %||% 'not uploaded'}
          "
            )
          )
        ),
        distance = list(
          header = "Distance network",
          color = "#FCEBEB",
          border = "#E24B4A",
          data = htmltools::HTML(
            stringr::str_glue(
              "Files: 
              <br>
                edge - {input$dist_edge_file$name %||% 'not uploaded'}
              <br>
                meta - {input$dist_meta_file$name %||% 'not uploaded'}
          "
            )
          )
        ),
        rds = list(
          header = "Previous network",
          color = "#43d471",
          border = "#0e5d3a",
          data = htmltools::HTML(
            stringr::str_glue(
              "Files:
                <br>
                  rds - {input$rds_file$name %||% 'not uploaded'}
          "
            )
          )
        )
      )

      output$tab <- shiny::renderTable({
        shiny::req(r$full_network())
        get_network_summary(r$full_network())
      })

      # Assemble formatted HTML output
      shiny::tagList(
        # Conditional callout block
        shiny::tags$div(
          shiny::tags$p(
            shiny::tags$strong(conditional_section$header)
          ),
          shiny::tags$p(conditional_section$data),
          style = paste0(
            "background: ",
            conditional_section$color,
            ";",
            "border-left: 3px solid ",
            conditional_section$border,
            ";",
            "padding: 8px 12px;",
            "border-radius: 0 4px 4px 0;",
            "font-weight: 500;",
            "margin-top: 10px;"
          )
        )
      )
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

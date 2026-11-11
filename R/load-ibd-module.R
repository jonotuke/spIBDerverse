loadibdInput <- function(id) {
  shiny::tagList(
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
    shiny::fileInput(
      shiny::NS(id, "ibd_meta_file"),
      "Upload a meta data file (nodes)"
    ) |>
      hover_tooltip(
        "Upload your meta data for the individuals. 
          This can include any meta data you might like to 
          plot or test. The first column should be called \"iid\"."
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
      )
  )
}
loadibdOutput <- function(id) {
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
loadibdServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print("IBD data")
      print(ibd_data()$network)
    })
    ibd_data <- shiny::reactive({
      if (
        is.null(input$ibd_edge_file) |
          is.null(input$ibd_meta_file)
      ) {
        return(NULL)
      }
      capture_conditions(
        load_ibd(
          input$ibd_edge_file$datapath,
          input$ibd_meta_file$datapath,
          ibd_co = ibd_cutoffs(),
          frac_co = input$ibd_frac_cutoff,
          filter_on_meta = input$ibd_filter
        )
      )
    })

    ibd_cutoffs <- shiny::reactive({
      stringr::str_split(input$ibd_cutoffs, ",") |>
        purrr::pluck(1) |>
        purrr::map_dbl(as.numeric)
    })
    shiny::observeEvent(ibd_data(), {
      shiny::req(ibd_data()$network)
      r$full_network <- shiny::reactive({
        ibd_data()$network
      })
    })

    output$tab <- shiny::renderTable({
      res <- ibd_data()
      shiny::validate(
        shiny::need(res, "Please upload IBD and meta file"),
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

loadibdApp <- function() {
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    example_network
  })
  ui <- shiny::fluidPage(
    loadibdInput("ibdload"),
    loadibdOutput("ibdload")
  )
  server <- function(input, output, session) {
    loadibdServer("ibdload", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  loadibdApp() |> print()
}

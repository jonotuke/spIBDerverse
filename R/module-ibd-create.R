ibdInput <- function(id) {
  shiny::tagList(
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

ibdOutput <- function(id) {
  shiny::tagList(
    # shiny::verbatimTextOutput(
    #   shiny::NS(id, "debug")
    # ),
    DT::dataTableOutput(
      shiny::NS(id, "node_dt")
    )
  )
}
ibdServer <- function(id, input_network, r) {
  shiny::moduleServer(id, function(input, output, session) {
    ibd_data <- shiny::reactive({
      shiny::req(input$ibd_file)
      tryCatch(
        {
          df <- readr::read_tsv(input$ibd_file$datapath)
          return(df)
        },
        error = function(e) {
          conditionMessage(e)
          return(NULL)
        }
      )
    })
    # Validate IBD file
    ibd_iv <- shinyvalidate::InputValidator$new()
    ibd_iv$condition(~ !is.null(input$ibd_file))
    ibd_iv$add_rule("ibd_file", function(value) {
      data <- ibd_data()
      if (is.null(data)) {
        return("Could not read file. Is it a valid TSV?")
      }
      actual_cols <- names(data)
      missing_cols <- setdiff(c("iid1", "iid2"), actual_cols)
      if (length(missing_cols) > 0) {
        return(paste(
          "Missing required columns:",
          paste(missing_cols, collapse = ", ")
        ))
      }
      NULL
    })
    ibd_iv$enable()
    # Validate META file
    meta_data <- shiny::reactive({
      shiny::req(input$meta_file)
      tryCatch(
        {
          df <- readr::read_tsv(input$meta_file$datapath)
          return(df)
        },
        error = function(e) {
          conditionMessage(e)
          return(NULL)
        }
      )
    })
    meta_iv <- shinyvalidate::InputValidator$new()
    meta_iv$condition(~ !is.null(input$meta_file))
    meta_iv$add_rule("meta_file", function(value) {
      data <- meta_data()
      if (is.null(data)) {
        return("Could not read file. Is it a valid TSV?")
      }
      actual_cols <- names(data)
      missing_cols <- setdiff(c("iid"), actual_cols)
      if (length(missing_cols) > 0) {
        return(paste(
          "Missing required columns:",
          paste(missing_cols, collapse = ", ")
        ))
      }
      NULL
    })
    meta_iv$enable()
    output$node_dt <- DT::renderDataTable({
      DT::datatable(
        get_node_info(network()),
        options = list(pageLength = 100)
      )
    })
    cutoffs <- shiny::reactive({
      stringr::str_split(input$cutoffs, ",") |>
        purrr::pluck(1) |>
        purrr::map_dbl(as.numeric)
    })
    file_network <- shiny::reactive({
      shiny::req(input$ibd_file)
      shiny::req(input$meta_file)
      load_ibd_network(
        input$ibd_file$datapath,
        input$meta_file$datapath,
        ibd_co = cutoffs(),
        frac_co = input$frac_cutoff,
        filter_on_meta = input$filter
      )
    })
    ## full network ----
    full_network <- shiny::reactive({
      tryCatch(
        {
          file_network()
        },
        shiny.silent.error = function(e) {
          input_network
        }
      )
    })
    network <- shiny::reactive({
      filter_network(
        full_network(),
        node_inc = input$node_inc,
        node_exc = input$node_exc
      )
    })
    output$debug <- shiny::renderPrint({
      print(input$meta_file)
      print(meta_data())
    })
    r$network <- shiny::reactive(network())
    shiny::reactive(network())
  })
}
ibdcreateApp <- function(input_network) {
  all_vars <- get_node_attributes(input_network)
  r <- shiny::reactiveValues()
  r$full_network <- shiny::reactive({
    input_network
  })
  options(shiny.maxRequestSize = Inf)
  ui <- shiny::fluidPage(
    ibdInput("ibd"),
    networkFilterInput("filter", all_vars),
    nodeOutput("node")
  )
  server <- function(input, output, session) {
    network <- ibdServer("ibd", input_network, r = r)
    networkFilterServer("filter", r = r)
    nodeServer("node", r = r)
  }
  shiny::shinyApp(ui, server)
}
# ibdcreateApp(example_network) |> print()

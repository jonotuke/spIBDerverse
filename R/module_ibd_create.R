ibdInput <- function(id) {
  shiny::tagList(
    shiny::fileInput(
      shiny::NS(id, "ibd_file"),
      "Upload a IBD file"
    ),
    shiny::fileInput(
      shiny::NS(id, "meta_file"),
      "Upload a meta file"
    ),
    shiny::textInput(
      shiny::NS(id, "cutoffs"),
      label = "Please enter cutoffs with commas between",
      value = "0,2,1,0"
    )
  )
}
ibdOutput <- function(id) {
  shiny::tagList(
    # shiny::verbatimTextOutput(
    #   shiny::NS(id, "cutoffs")
    # ),
    DT::dataTableOutput(
      shiny::NS(id, "node_dt")
    )
  )
}
ibdServer <- function(id, network) {
  shiny::moduleServer(id, function(input, output, session) {
    output$cutoffs <- shiny::renderPrint({
      print(cutoffs())
    })
    output$node_dt <- DT::renderDataTable({
      get_node_info(network())
    })
    cutoffs <- shiny::reactive({
      stringr::str_split(input$cutoffs, ",") |>
        purrr::pluck(1) |>
        purrr::map_dbl(as.numeric)
    })
    file_network <- shiny::reactive({
      shiny::req(input$ibd_file)
      shiny::req(input$meta_file)
      create_ibd_network(
        input$ibd_file$datapath,
        input$meta_file$datapath,
        # ibd_co = c(0, 2, 1, 0)
        ibd_co = cutoffs()
      )
    })
    ## full network ----
    network <- shiny::reactive({
      tryCatch(
        {
          file_network()
        },
        shiny.silent.error = function(e) {
          shiny::showNotification(
            "Using example network",
            type = "warning"
          )
          example_network
        }
      )
    })
    shiny::reactive(network())
  })
}
ibdcreateApp <- function(network) {
  ui <- shiny::fluidPage(
    ibdInput("ibd"),
    ibdOutput("ibd"),
    shiny::verbatimTextOutput("network_txt")
  )
  server <- function(input, output, session) {
    network <- ibdServer("ibd", network)
    output$network_txt <- shiny::renderPrint(network())
  }
  shiny::shinyApp(ui, server)
}
# ibdcreateApp(example_network) |> print()

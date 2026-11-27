networkplotInput <- function(
  id,
  all_vars,
  cat_vars,
  edge_vars,
  num_vars,
  label_vars
) {
  shiny::tagList(
    shiny::numericInput(
      shiny::NS(id, "seed"),
      label = "Set seed",
      value = 1000
    ) |>
      hover_tooltip(
        "Number to generate new network layout. Change this number to rearrange the nodes."
      ),
    network_ui(
      id,
      all_vars = all_vars,
      cat_vars = cat_vars,
      edge_vars = edge_vars,
      num_vars = num_vars,
      label_vars = label_vars
    )
  )
}

networkplotOutput <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::plotOutput(ns("plot"), height = "800px"),
    shiny::actionButton(ns("save"), "Set as export plot")
  )
}

# SERVER ----

networkplotServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    network_ui_server(input, session, r)

    p <- shiny::reactive({
      net <- r$network()
      if (is.null(net)) {
        return(NULL)
      }
      rlang::exec(
        plot_network,
        net,
        seed = input$seed,
        layout = input$layout,
        !!!network_plot_args(input)
      )
    })

    output$plot <- shiny::renderPlot(p())

    shiny::observeEvent(input$save, {
      r$export <- p
    })
  })
}

# APP ----

networkplotApp <- function(network_input) {
  r <- network_app_values(network_input)

  ui <- shiny::fluidPage(
    theme = bslib::bs_theme(version = 5),
    title = "Network plot",
    rlang::exec(
      networkplotInput,
      "networkplot",
      !!!network_vars(network_input)
    ),
    networkplotOutput("networkplot"),
    shiny::plotOutput("export")
  )

  server <- function(input, output, session) {
    networkplotServer("networkplot", r = r)

    output$export <- shiny::renderPlot(r$export())
  }

  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  networkplotApp(example_network) |> print()
}

clusteringInput <- function(id, all_vars) {
  clustering_vars <- internal_df() |>
    dplyr::filter(type == "clustering")
  shiny::tagList(
    shiny::radioButtons(
      shiny::NS(id, "pred"),
      "Choose attributes",
      choices <- c("none", all_vars)
    ),
    shiny::radioButtons(
      shiny::NS(id, "cluster"),
      "Clustering measure",
      choiceNames = clustering_vars$full_name,
      choiceValues = clustering_vars$name,
      selected = ".louvain"
    ),
    shiny::numericInput(
      shiny::NS(id, "digits"),
      "Decimal places",
      value = 2,
      min = 0,
      max = 10,
      step = 1
    ),
    shiny::numericInput(
      shiny::NS(id, "n_levels"),
      "Number of levels allowed",
      value = 10,
      min = 3,
      max = 30,
      step = 1
    ),
    shiny::numericInput(
      shiny::NS(id, "font"),
      "Font size",
      min = 5,
      max = 30,
      value = 20,
      step = 1
    )
  )
}
clusteringOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    ),
    shiny::plotOutput(
      shiny::NS(id, "conf_mat")
    )
  )
}
clusteringServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    cluster_df <- shiny::reactive({
      get_clustering_measures(r$network(), input$pred, input$cluster)
    })
    output$tab <- DT::renderDataTable({
      df <- cluster_df()
      digits <- input$digits
      if (is.null(digits) || is.na(digits) || digits < 0) {
        digits <- 0
      }
      num_cols <- df |>
        dplyr::select(dplyr::where(is.double)) |>
        names()
      tab <- DT::datatable(df)
      if (length(num_cols) > 0) {
        tab <- DT::formatRound(tab, columns = num_cols, digits = digits)
      }
      tab
    })
    output$conf_mat <- shiny::renderPlot({
      shiny::req(input$pred != "none")
      tryCatch(
        plot_clustering_confusion(
          g = r$network(),
          pred = input$pred,
          cluster = input$cluster,
          n_levels = input$n_levels,
          base_size = input$font
        ),
        clustering_confusion_too_many_levels = function(w) {
          shiny::validate(shiny::need(FALSE, conditionMessage(w)))
        },
        clustering_confusion_not_categorical = function(e) {
          shiny::validate(shiny::need(FALSE, conditionMessage(e)))
        }
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateRadioButtons(
        session,
        "pred",
        choices = c(
          "none",
          get_node_attributes(
            r$full_network(),
            "all"
          )
        )
      )
    })
  })
}
clusteringApp <- function(network_input) {
  cat_var <- get_node_attributes(
    network_input,
    "all",
  )
  ui <- shiny::fluidPage(
    clusteringInput("cluster", cat_var),
    clusteringOutput("cluster")
  )
  server <- function(input, output, session) {
    r <- shiny::reactiveValues()

    r$network <- shiny::reactive(network_input)
    r$full_network <- shiny::reactive(network_input)
    clusteringServer("cluster", r = r)
  }
  shiny::shinyApp(ui, server)
}
if (sys.nframe() == 5) {
  clusteringApp(example_network) |> print()
}

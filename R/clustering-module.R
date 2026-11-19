clusteringInput <- function(id, all_vars) {
  clustering_vars <- internal_df() |>
    dplyr::filter(type == "clustering")
  shiny::tagList(
    bslib::accordion(
      open = NULL,
      bslib::accordion_panel(
        "Preds and cluster",
        value = "Preds and clusters",
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
      ),
      bslib::accordion_panel(
        "Confusion matrix plot",
        icon = shiny::icon("table-cells"),
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
        ),
        palette_chooser(shiny::NS(id, "fill_pal"), "Fill palette", type = "cat")
      )
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
    ),
    shiny::actionButton(shiny::NS(id, "save_conf"), "Set as export plot"),
    shiny::plotOutput(
      shiny::NS(id, "ca_plot")
    ),
    shiny::actionButton(shiny::NS(id, "save_ca_plot"), "Set as export plot")
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
      conf_mat()
    })
    conf_mat <- shiny::reactive({
      shiny::req(input$pred != "none")
      tryCatch(
        plot_clustering_confusion(
          g = r$network(),
          pred = input$pred,
          cluster = input$cluster,
          n_levels = input$n_levels,
          base_size = input$font,
          fill_pal = input$fill_pal
        ),
        error = function(w) {
          shiny::validate(shiny::need(FALSE, conditionMessage(w)))
        },
        warning = function(e) {
          shiny::validate(shiny::need(FALSE, conditionMessage(e)))
        }
      )
    })
    shiny::observeEvent(input$save_conf, {
      r$export <- conf_mat
    })

    output$ca_plot <- shiny::renderPlot({
      ca_plot()
    })
    ca_plot <- shiny::reactive({
      shiny::req(input$pred != "none")
      tryCatch(
        plot_ca_clusters(
          g = r$network(),
          pred = input$pred,
          cluster = input$cluster
        ),
        error = function(e) {
          shiny::validate(shiny::need(FALSE, conditionMessage(e)))
        }
      )
    })
    shiny::observeEvent(input$save_ca_plot, {
      r$export <- ca_plot
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

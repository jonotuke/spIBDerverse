#' centrality input
#' @noRd
centralityInput <- function(id, cat_vars) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "centrality"),
      "Centrality measure to plot",
      choices = c(
        "Degree" = ".degree",
        "Closeness" = ".closeness",
        "Betweenness" = ".betweenness",
        "Eigencentrality" = ".eigencentrality"
      ),
      selected = ".degree"
    ),
    shiny::checkboxGroupInput(
      shiny::NS(id, "preds"),
      "Choose attributes to stratify on",
      choices = cat_vars
    ),
    shiny::numericInput(
      shiny::NS(id, "places"),
      label = "Choose decimal places for table",
      min = 0,
      max = 10,
      step = 1,
      value = 2
    ),

    palette_chooser(
      id = shiny::NS(id, "pal"),
      label = "Choose palette",
      type = "cat"
    ),
    shiny::actionButton(
      shiny::NS(id, "run_sim"),
      "Run permutation test",
      icon = shiny::icon("arrows-rotate"),
      class = "btn-primary"
    ),
    shiny::checkboxInput(
      shiny::NS(id, "rotate"),
      "Rotate x-axis"
    ),
    shiny::checkboxInput(
      shiny::NS(id, "log"),
      "Log-transform y-axis"
    )
  )
}
#' centrality output
#' @noRd
centralityOutput <- function(id) {
  shiny::tagList(
    DT::dataTableOutput(
      shiny::NS(id, "tab")
    ),
    shiny::downloadButton(
      shiny::NS(id, "down"),
      "Download table"
    ),
    shiny::plotOutput(
      shiny::NS(id, "hist")
    ),
    gt::gt_output(
      shiny::NS(id, "test")
    ),
    shiny::actionButton(
      shiny::NS(id, "save"),
      "Set as export plot"
    )
  )
}
#' centrality server
#' @noRd
centralityServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    central_df <- shiny::reactive({
      get_centrality_measures(r$network(), input$preds)
    })
    output$tab <- DT::renderDataTable({
      DT::datatable({
        central_df()
      }) |>
        DT::formatRound(
          c(
            ".degree",
            ".closeness",
            ".betweenness",
            ".eigencentrality"
          ),
          input$places
        )
    })
    output$down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-centrality.tsv")
      },
      content = function(file) {
        readr::write_tsv(
          central_df(),
          file
        )
      }
    )
    output$hist <- shiny::renderPlot({
      p()
    })
    p <- shiny::reactive({
      validate_try(
        plot_centrality(
          r$network(),
          centrality = input$centrality,
          preds = input$preds,
          rotate = input$rotate,
          pal = input$pal,
          log_trans = input$log
        )
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateCheckboxGroupInput(
        session,
        "preds",
        choices = c(
          get_node_attributes(r$full_network(), "cat")
        )
      )
    })
    shiny::observeEvent(input$save, {
      r$export <- shiny::reactive(
        p()
      )
    })
    output$test <- gt::render_gt({
      shiny::req(input$preds)
      validate_try(
        test_centralities(
          r$network(),
          centrality = input$centrality,
          preds = input$preds
        ) |>
          get_centrality_gt()
      )
    }) |>
      shiny::bindEvent(input$run_sim)
  })
}
#' centrality app
#' @noRd
centralityApp <- function(network_input) {
  cat_var <- get_node_attributes(network_input, "cat")
  ui <- shiny::fluidPage(
    centralityInput("central", cat_var),
    centralityOutput("central")
  )
  server <- function(input, output, session) {
    r <- shiny::reactiveValues()

    r$network <- shiny::reactive(network_input)
    r$full_network <- shiny::reactive(network_input)
    centralityServer("central", r = r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  centralityApp(example_network) |> print()
}

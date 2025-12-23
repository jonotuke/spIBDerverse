ergmInput <- function(id, meta) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "preds"),
      "Select Predictors",
      choices = meta
    ),
    shiny::radioButtons(
      shiny::NS(id, "ergm_coef"),
      label = "ERGM type",
      choices = c(
        "Coefficients" = "theta",
        "Fold changes" = "phi"
      ),
      selected = "theta",
    ),
    shiny::radioButtons(
      shiny::NS(id, "measure"),
      label = "Measure",
      choices = c(
        "AIC",
        "BIC"
      ),
      selected = "BIC"
    ),
    shiny::checkboxInput(
      shiny::NS(id, "top_5"),
      label = "Show just top 5"
    ),
    shiny::sliderInput(
      shiny::NS(id, "text_size"),
      label = "Text size",
      min = 5,
      max = 20,
      value = 8
    ),
    shiny::sliderInput(
      shiny::NS(id, "text_angle"),
      label = "Text angle",
      min = 0,
      max = 90,
      value = 90,
      step = 15
    ),
    shiny::checkboxInput(
      shiny::NS(id, "abbr"),
      label = "Abbreviate models"
    ),
    shiny::checkboxInput(
      shiny::NS(id, "ergm_trim"),
      label = "Trim coefficients",
      value = TRUE
    )
  )
}
ergmOutput <- function(id) {
  shiny::tagList(
    shiny::h4("ERGMs BIC"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_aic_plot")
    ),
    shiny::actionButton(
      shiny::NS(id, "bic_save"),
      "Set as export plot"
    ),
    DT::dataTableOutput(
      shiny::NS(id, "ergm_aic_tab")
    ),
    shiny::h4("ERGMs coefficients"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_coef_plot"),
      height = "800px"
    ),
    shiny::actionButton(
      shiny::NS(id, "coef_save"),
      "Set as export plot"
    )
  )
}
ergmServer <- function(id, df, store) {
  shiny::moduleServer(id, function(input, output, session) {
    ergm <- shiny::reactive(
      get_ergms(df(), input$preds)
    )
    output$ergm_aic_tab <- DT::renderDataTable({
      DT::datatable(
        get_ergm_bic(
          ergm()
        )
      ) |>
        DT::formatRound(
          columns = c('AIC', 'BIC'),
          digits = 2
        )
    })
    bic_plot <- shiny::reactive({
      plot_ergm_bic(
        ergm(),
        text_size = input$text_size,
        text_angle = input$text_angle,
        abbr = input$abbr,
        measure = input$measure,
        top_5 = input$top_5
      )
    })
    output$ergm_aic_plot <- shiny::renderPlot({
      bic_plot()
    })
    coef_plot <- shiny::reactive({
      plot_ergm_coef(
        ergm(),
        type = input$ergm_coef,
        trim = input$ergm_trim
      )
    })
    output$ergm_coef_plot <- shiny::renderPlot({
      coef_plot()
    })
    shiny::observeEvent(df(), {
      shiny::updateCheckboxGroupInput(
        session,
        "preds",
        choices = igraph::vertex_attr_names(df())
      )
    })
    shiny::observeEvent(input$bic_save, {
      store$export <- shiny::reactive(
        bic_plot()
      )
    })
    shiny::observeEvent(input$coef_save, {
      store$export <- shiny::reactive(
        coef_plot()
      )
    })
  })
}
ergmApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    ergmInput("ergm", meta),
    ergmOutput("ergm"),
    shiny::plotOutput("debug")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ergmServer("ergm", network, store)
    store <- shiny::reactiveValues(
      export = shiny::reactive({
        plot_default_image()
      })
    )
    output$debug <- shiny::renderPlot({
      store$export()
    })
  }
  shiny::shinyApp(ui, server)
}
# ergmApp(example_network) |> print()

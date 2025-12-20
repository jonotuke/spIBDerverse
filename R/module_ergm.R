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
    shiny::downloadButton(
      shiny::NS(id, "bic_down"),
      "Download plot"
    ),
    DT::dataTableOutput(
      shiny::NS(id, "ergm_aic_tab")
    ),
    shiny::h4("ERGMs coefficients"),
    shiny::plotOutput(
      shiny::NS(id, "ergm_coef_plot"),
      height = "800px"
    ),
    shiny::downloadButton(
      shiny::NS(id, "coef_down"),
      "Download plot"
    ),
  )
}
ergmServer <- function(id, df) {
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
        abbr = input$abbr
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
    output$bic_down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-ergm-bic.pdf")
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          bic_plot(),
          width = 10,
          height = 10
        )
      }
    )
    output$coef_down <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-ergm-coef.pdf")
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          coef_plot(),
          width = 10,
          height = 10
        )
      }
    )
  })
}
ergmApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    ergmInput("ergm", meta),
    ergmOutput("ergm")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ergmServer("ergm", network)
  }
  shiny::shinyApp(ui, server)
}
# ergmApp(example_network) |> print()

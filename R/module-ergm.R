ergmInput <- function(id, all_vars, g) {
  shiny::tagList(
    shiny::checkboxGroupInput(
      shiny::NS(id, "preds"),
      "Select Predictors",
      choices = all_vars
    ) |>
      bslib::tooltip(
        htmltools::HTML(
          "Select the predictors to include in the model. For each variable you can choose which level of complexity to include. If a categorical value has only two levels, then nodematch(diff) and nodemix are equivalent, and nodemix is removed.
      <br><br>
        Quantitative: nodecov (sum of values) or absdiff (absolute difference in values
      <br><br>
        Categorical: nodematch (do the variables match or not), nodematch(diff) (do the variables match or not, and if so, which level is it) or nodemix (the combination of levels).
      <br><br>
        See https://doi.org/10.1093/genetics/iyag053 for full details."
        )
      ),
    shiny::uiOutput(
      shiny::NS(id, "pred_types")
    ),
    shiny::radioButtons(
      shiny::NS(id, "ergm_coef"),
      label = "ERGM type",
      choices = c(
        "Coefficients" = "theta",
        "Fold changes" = "phi"
      ),
      selected = "phi"
    ) |>
      bslib::tooltip(
        "Report model coefficients as just coefficients, or with the fold change effect of the variable."
      ),
    shiny::radioButtons(
      shiny::NS(id, "measure"),
      label = "Measure",
      choices = c(
        "AIC",
        "BIC"
      ),
      selected = "BIC"
    ) |>
      bslib::tooltip(
        "Use AIC or BIC for model selection. We suggest BIC based on a simulation study."
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
      value = 8,
    ),
    shiny::sliderInput(
      shiny::NS(id, "text_angle"),
      label = "Text angle",
      min = 0,
      max = 90,
      value = 90,
      step = 15
    ) |>
      bslib::tooltip(
        "Change the angle at which the x-axis model names appear. Useful when long names make the model selection plot too small."
      ),
    shiny::checkboxInput(
      shiny::NS(id, "abbr"),
      label = "Abbreviate models"
    ) |>
      bslib::tooltip(
        "Shorten the model names on the model selection plot."
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
      shiny::NS(id, "ergm_aic_plot"),
      height = "600px"
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
      shiny::NS(id, "ergm_coef_plot")
    ),
    gt::gt_output({
      shiny::NS(id, "ergm_coef_tab")
    }),
    shiny::actionButton(
      shiny::NS(id, "coef_save"),
      "Set as export plot"
    )
  )
}
ergmServer <- function(id, df, store) {
  shiny::moduleServer(id, function(input, output, session) {
    ergm <- shiny::reactive(
      get_ergms(df(), input$preds, pred_type_vec())
    )
    output$ergm_aic_tab <- DT::renderDataTable({
      DT::datatable(ergm_bic()) |>
        DT::formatRound(
          columns = c('AIC', 'BIC'),
          digits = 2
        )
    })
    ergm_bic <- shiny::reactive({
      get_ergm_bic(
        ergm()
      )
    })
    selected_rows_data <- shiny::reactive({
      s <- input$ergm_aic_tab_rows_selected
      if (length(s)) {
        ergm_bic()[s, , drop = FALSE] |> dplyr::pull(Model)
      }
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
        trim = input$ergm_trim,
        models = selected_rows_data()
      )
    })
    output$ergm_coef_plot <- shiny::renderPlot({
      coef_plot()
    })
    output$ergm_coef_tab <- gt::render_gt({
      shiny::req(selected_rows_data())
      tab_ergm_coef(
        ergm(),
        models = selected_rows_data()
      ) |>
        gt::gt() |>
        gt::fmt_number() |>
        gt::fmt_scientific("p.value") |>
        gt::tab_style(
          style = list(
            gt::cell_fill(color = "grey80"),
            gt::cell_text(weight = "bold")
          ),
          locations = gt::cells_row_groups()
        )
    })
    shiny::observeEvent(df(), {
      shiny::updateCheckboxGroupInput(
        session,
        "preds",
        choices = get_node_attributes(df())
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
    output$pred_types <- shiny::renderUI({
      purrr::map(
        input$preds,
        \(x) make_ergm_ui(x, df(), x, id)
      )
    })
    pred_type_vec <- shiny::reactive({
      purrr::map_chr(
        input$preds,
        \(x) stringr::str_c(input[[x]], collapse = "|")
      )
    })
  })
}
make_ergm_ui <- function(pred, g, label, id) {
  if (!is.null(pred)) {
    type <- class(igraph::vertex_attr(g, pred))
  } else {
    type <- "non selected"
  }
  if (type == "numeric") {
    shiny::checkboxGroupInput(
      shiny::NS(id, label),
      label = pred,
      choices = c("nodecov", "absdiff"),
      selected = "nodecov"
    )
  } else if (type == "character") {
    n_levels <- nlevels(factor(igraph::vertex_attr(g, pred)))
    if (n_levels <= 2) {
      shiny::checkboxGroupInput(
        shiny::NS(id, label),
        label = pred,
        choices = c("nodematch", "nodematch(diff)"),
        selected = "nodematch"
      )
    } else {
      shiny::checkboxGroupInput(
        shiny::NS(id, label),
        label = pred,
        choices = c("nodematch", "nodematch(diff)", "nodemix"),
        selected = "nodematch"
      )
    }
  } else {
    NULL
  }
}
ergmApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  ui <- shiny::fluidPage(
    ergmInput("ergm", all_vars, network_input),
    shiny::verbatimTextOutput(outputId = "debug"),
    ergmOutput("ergm")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ergmServer("ergm", network, store)
    store <- shiny::reactiveValues(
      export = shiny::reactive({
        plot_default_image()
      })
    )
  }
  shiny::shinyApp(ui, server)
}
# ergmApp(example_network) |> print()

ringbauerInput <- function(id, cat_vars) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "grp"),
      label = "Choose group to calculate Ringbauer matrix on",
      choices = c("none", cat_vars),
      selected = "none"
    ),
    shiny::sliderInput(
      shiny::NS(id, "font_size"),
      label = "Font size",
      min = 1,
      max = 10,
      step = 1,
      value = 1
    ) |>
      bslib::tooltip(
        "Change font size for axis labels and cell counts (matrix plot)."
      ),
    shiny::sliderInput(
      shiny::NS(id, "margin"),
      label = "Heatmap margin",
      min = 4,
      max = 20,
      step = 1,
      value = 4
    ) |>
      bslib::tooltip(
        "Increase or decrease the space around the edge of the plot (matrix plot). Useful when labels are too large to be seen properly."
      ),
    shiny::checkboxInput(
      shiny::NS(id, "abbr"),
      label = "Abbreviate labels",
      value = FALSE
    ),
    shiny::checkboxInput(
      shiny::NS(id, "addSize"),
      label = "Add size",
      value = FALSE
    ) |>
      bslib::tooltip(
        "Add the sample size to the axis labels (matrix plot)."
      ),
    shiny::checkboxInput(
      shiny::NS(id, "addPercent"),
      label = "Add percent",
      value = FALSE
    ) |>
      bslib::tooltip(
        "Add the percentages to the cell counts (matrix plot)."
      ),
    shiny::checkboxInput(
      shiny::NS(id, "show_sign"),
      "Show significance",
      value = FALSE
    ) |>
      bslib::tooltip(
        "Colours pairs of levels as significant (yellow) or not (black) compared to the average overall connectedness (connectivity plot)."
      ),
    shiny::checkboxInput(
      shiny::NS(id, "filter_sign"),
      "Filter out non-significant",
      value = FALSE
    ) |>
      bslib::tooltip(
        "Makes non-significant pairs transparent (connectivity plot)."
      )
  )
}
ringbauerOutput <- function(id) {
  shiny::tagList(
    shiny::h1("Matrix plot"),
    shiny::plotOutput(
      shiny::NS(id, "ringbauer_plot"),
      height = "800px"
    ),
    shiny::actionButton(
      shiny::NS(id, "ringbauer_save"),
      "Set as export plot"
    ),
    shiny::h1("Connectivity plot"),
    shiny::plotOutput(
      shiny::NS(id, "homophily_plot")
    ),
    shiny::actionButton(
      shiny::NS(id, "homophily_save"),
      "Set as export plot"
    ),
  )
}
ringbauerServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    RM <- shiny::reactive({
      shiny::req(input$grp != "none")
      get_ringbauer_measures(
        r$network(),
        input$grp
      )
    })
    output$ringbauer_plot <- shiny::renderPlot({
      ringbauer_p()
    })
    ringbauer_p <- shiny::reactive({
      RM() |>
        convert_ringbauer_measures(
          abbr = input$abbr,
          addSize = input$addSize,
          addPercent = input$addPercent
        ) |>
        plot_ringbauer(
          label_size = input$font_size,
          label_margin = input$margin
        )
      grDevices::recordPlot()
    })
    output$homophily_plot <- shiny::renderPlot({
      homophily_p()
    })
    homophily_p <- shiny::reactive({
      RM() |>
        plot_homophily(
          show_sign = input$show_sign,
          filter_sign = input$filter_sign
        )
    })
    shiny::observeEvent(r$network(), {
      shiny::updateSelectInput(
        session,
        "grp",
        choices = c("none", get_node_attributes(r$network(), "cat"))
      )
    })
    shiny::observeEvent(input$homophily_save, {
      r$export <- shiny::reactive(
        homophily_p()
      )
    })
    shiny::observeEvent(input$ringbauer_save, {
      r$export <- shiny::reactive(
        ringbauer_p()
      )
    })
  })
}
ringbauerApp <- function(network_input) {
  cat_vars <- get_node_attributes(network_input, "cat")
  r <- shiny::reactiveValues()
  r$network <- shiny::reactive({
    network_input
  })
  r$export <- shiny::reactive({
    plot_default_image()
  })

  ui <- shiny::fluidPage(
    ringbauerInput("ringbauer", cat_vars),
    ringbauerOutput("ringbauer"),
    shiny::plotOutput("debug")
  )
  server <- function(input, output, session) {
    ringbauerServer("ringbauer", r = r)
    output$debug <- shiny::renderPlot({
      r$export()
    })
  }
  shiny::shinyApp(ui, server)
}
# ringbauerApp(example_network) |> print()

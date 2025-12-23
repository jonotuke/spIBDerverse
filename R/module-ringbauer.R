ringbauerInput <- function(id, meta) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "grp"),
      label = "Choose group to calculate Ringbauer matrix on",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::sliderInput(
      shiny::NS(id, "font_size"),
      label = "Font size",
      min = 1,
      max = 10,
      step = 1,
      value = 1
    ),
    shiny::sliderInput(
      shiny::NS(id, "margin"),
      label = "Heatmap margin",
      min = 4,
      max = 20,
      step = 1,
      value = 4
    ),
    shiny::checkboxInput(
      shiny::NS(id, "abbr"),
      label = "Abbreviate labels",
      value = TRUE
    )
  )
}
ringbauerOutput <- function(id) {
  shiny::tagList(
    shiny::plotOutput(
      shiny::NS(id, "ringbauer_plot"),
      height = "800px"
    ),
    # shiny::downloadButton(
    #   shiny::NS(id, "ringbauer_down")
    # ),
    shiny::actionButton(
      shiny::NS(id, "ringbauer_save"),
      "Set as export plot"
    ),
    shiny::plotOutput(
      shiny::NS(id, "homophily_plot")
    ),
    shiny::actionButton(
      shiny::NS(id, "homophily_save"),
      "Set as export plot"
    ),
  )
}
ringbauerServer <- function(id, df, store) {
  shiny::moduleServer(id, function(input, output, session) {
    RM <- shiny::reactive({
      shiny::req(input$grp != "none")
      get_ringbauer_measures(
        df(),
        input$grp
      )
    })
    output$ringbauer_plot <- shiny::renderPlot({
      ringbauer_p()
    })
    ringbauer_p <- shiny::reactive({
      RM() |>
        convert_ringbauer_measures(
          abbr = input$abbr
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
        plot_homophily()
    })
    shiny::observeEvent(df(), {
      shiny::updateSelectInput(
        session,
        "grp",
        choices = c("none", igraph::vertex_attr_names(df()))
      )
    })
    shiny::observeEvent(input$homophily_save, {
      store$export <- shiny::reactive(
        homophily_p()
      )
    })
    shiny::observeEvent(input$ringbauer_save, {
      store$export <- shiny::reactive(
        ringbauer_p()
      )
    })
    # output$ringbauer_down <- shiny::downloadHandler(
    #   filename = function() {
    #     paste0(lubridate::today(), "-ringbauer.pdf")
    #   },
    #   content = function(file) {
    #     grDevices::pdf(file, width = 10, height = 10)
    #     RM() |>
    #       convert_ringbauer_measures(
    #         abbr = input$abbr
    #       ) |>
    #       plot_ringbauer(
    #         label_size = input$font_size,
    #         label_margin = input$margin
    #       )
    #     grDevices::dev.off()
    #   }
    # )
  })
}
ringbauerApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    ringbauerInput("ringbauer", meta),
    ringbauerOutput("ringbauer"),
    shiny::plotOutput("debug")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ringbauerServer("ringbauer", network, store)
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
# ringbauerApp(example_network) |> print()

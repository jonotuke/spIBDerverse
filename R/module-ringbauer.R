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
      min = 3,
      max = 10,
      step = 1,
      value = 3
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
      shiny::NS(id, "plot"),
      height = "800px"
    ),
    shiny::plotOutput(
      shiny::NS(id, "homophily_plot")
    )
  )
}
ringbauerServer <- function(id, df) {
  shiny::moduleServer(id, function(input, output, session) {
    RM <- shiny::reactive({
      shiny::req(input$grp != "none")
      get_ringbauer_measures(
        df,
        input$grp
      )
    })
    output$plot <- shiny::renderPlot({
      RM() |>
        convert_ringbauer_measures(
          abbr = input$abbr
        ) |>
        plot_ringbauer(
          label_size = input$font_size,
          label_margin = input$margin
        )
    })
    output$homophily_plot <- shiny::renderPlot({
      RM() |>
        plot_homophily()
    })
  })
}
ringbauerApp <- function(network) {
  meta <- igraph::vertex_attr_names(network)
  ui <- shiny::fluidPage(
    ringbauerInput("ringbauer", meta),
    ringbauerOutput("ringbauer")
  )
  server <- function(input, output, session) {
    ringbauerServer("ringbauer", network)
  }
  shiny::shinyApp(ui, server)
}
# ringbauerApp(example_network) |> print()

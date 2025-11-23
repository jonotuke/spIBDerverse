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
      shiny::NS(id, "plot"),
      height = "800px"
    ),
    shiny::downloadButton(
      shiny::NS(id, "down_ringbauer"),
      "Download plot"
    ),
    shiny::plotOutput(
      shiny::NS(id, "homophily_plot")
    ),
    shiny::downloadButton(
      shiny::NS(id, "down_homophily"),
      "Download plot"
    )
  )
}
ringbauerServer <- function(id, df) {
  shiny::moduleServer(id, function(input, output, session) {
    RM <- shiny::reactive({
      shiny::req(input$grp != "none")
      get_ringbauer_measures(
        df(),
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
    output$down_homophily <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-homophily.pdf")
      },
      content = function(file) {
        ggplot2::ggsave(
          file,
          homophily_p(),
          width = 10,
          height = 10
        )
      }
    )
    output$down_ringbauer <- shiny::downloadHandler(
      filename = function() {
        paste0(lubridate::today(), "-ringbauer.pdf")
      },
      content = function(file) {
        pdf(file, width = 10, height = 10)
        RM() |>
          convert_ringbauer_measures(
            abbr = input$abbr
          ) |>
          plot_ringbauer(
            label_size = input$font_size,
            label_margin = input$margin
          )
        dev.off()
      }
    )
  })
}
ringbauerApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    ringbauerInput("ringbauer", meta),
    ringbauerOutput("ringbauer")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    ringbauerServer("ringbauer", network)
  }
  shiny::shinyApp(ui, server)
}
# ringbauerApp(example_network) |> print()

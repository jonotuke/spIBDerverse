leafletInput <- function(id, all_vars) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "lat"),
      label = "Choose latitude column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "lon"),
      label = "Choose longitude column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "leaflet_col"),
      label = "Choose node colour column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "label"),
      label = "Choose node label column",
      choices = c("none", all_vars),
      selected = "none"
    ),
    shiny::radioButtons(
      shiny::NS(id, "tile"),
      "Choose background map",
      choices = c(
        "Default",
        "Terrain",
        "Background"
      ),
      selected = "Default"
    )
  )
}
leafletOutput <- function(id) {
  shiny::tagList(
    leaflet::leafletOutput(
      shiny::NS(id, "map"),
      height = "800px"
    )
  )
}
leafletServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    output$map <- leaflet::renderLeaflet({
      if (input$lat != "none" & input$lon != "none") {
        plot_leaflet(
          r$network(),
          input$lat,
          input$lon,
          input$leaflet_col,
          input$tile,
          label = input$label
        )
      }
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "lat",
        choices = c("none", get_node_attributes(r$full_network()))
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "lon",
        choices = c("none", get_node_attributes(r$full_network()))
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "leaflet_col",
        choices = c(
          "none",
          get_node_attributes(r$full_network())
        )
      )
    })
    shiny::observeEvent(r$full_network(), {
      shiny::updateSelectInput(
        session,
        "label",
        choices = c(
          "none",
          get_node_attributes(r$full_network())
        )
      )
    })
  })
}
leafletApp <- function(network_input) {
  all_vars <- get_node_attributes(network_input)
  r <- shiny::reactiveValues()
  r$network <- shiny::reactive({
    network_input
  })
  ui <- shiny::fluidPage(
    leafletInput("leaflet", all_vars),
    leafletOutput("leaflet")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    x <- leafletServer(
      "leaflet",
      r = r
    )
  }
  shiny::shinyApp(ui, server)
}
# leafletApp(example_network) |> print()

leafletInput <- function(id, meta) {
  shiny::tagList(
    shiny::selectInput(
      shiny::NS(id, "lat"),
      label = "Choose lat column",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "lon"),
      label = "Choose long column",
      choices = c("none", meta),
      selected = "none"
    ),
    shiny::selectInput(
      shiny::NS(id, "leaflet_col"),
      label = "Choose node colour column",
      choices = c("none", meta),
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
  leaflet::leafletOutput(
    shiny::NS(id, "map"),
    height = "800px"
  )
}
leafletServer <- function(id, df) {
  shiny::moduleServer(id, function(input, output, session) {
    output$map <- leaflet::renderLeaflet({
      if (input$lat != "none" & input$lon != "none") {
        plot_leaflet(
          df(),
          input$lat,
          input$lon,
          input$leaflet_col,
          input$tile
        )
      }
    })
    shiny::observeEvent(df(), {
      shiny::updateSelectInput(
        session,
        "lat",
        choices = c("none", igraph::vertex_attr_names(df()))
      )
    })
    shiny::observeEvent(df(), {
      shiny::updateSelectInput(
        session,
        "lon",
        choices = c("none", igraph::vertex_attr_names(df()))
      )
    })
    shiny::observeEvent(df(), {
      shiny::updateSelectInput(
        session,
        "leaflet_col",
        choices = c("none", igraph::vertex_attr_names(df()))
      )
    })
  })
}
leafletApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    leafletInput("leaflet", meta),
    leafletOutput("leaflet")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive(network_input)
    leafletServer(
      "leaflet",
      network
    )
  }
  shiny::shinyApp(ui, server)
}
# leafletApp(example_network) |> print()

utils::globalVariables(
  c("displ", "cty")
)
mapplotInput <- function(id) {
  shiny::tagList(
    shiny::sliderInput(
      shiny::NS(id, "zoom"),
      label = "Zoom level",
      min = 5,
      max = 20,
      value = 9
    )
  )
}
mapplotOutput <- function(id) {
  shiny::tagList(
    shiny::plotOutput(
      shiny::NS(id, "plot"),
      height = "800px"
    ),
    shiny::verbatimTextOutput(
      shiny::NS(id, "debug")
    )
  )
}
mapplotServer <- function(id, leaflet_params, network) {
  shiny::moduleServer(id, function(input, output, session) {
    output$debug <- shiny::renderPrint({
      print("Module debug")
      print(leaflet_params)
      print(network)
      print(network_sf())
    })
    network_sf <- shiny::reactive({
      convert_sf(
        network,
        leaflet_params$lat,
        leaflet_params$lon,
        leaflet_params$col
      )
    })
    output$plot <- shiny::renderPlot({
      plot_map(network_sf(), zoom = input$zoom)
    })
  })
}
mapplotApp <- function(network) {
  ui <- shiny::fluidPage(
    mapplotInput("map"),
    mapplotOutput("map"),
  )
  server <- function(input, output, session) {
    params <- list(
      BB = list(
        north = -34.80481,
        east = 138.633,
        south = -34.8189,
        west = 138.6117
      ),
      lat = "lat",
      lon = "long",
      col = "site"
    )
    mapplotServer("map", params, network)
  }
  shiny::shinyApp(ui, server)
}
pacman::p_load(tidyverse)
mapplotApp(example_network) |> print()

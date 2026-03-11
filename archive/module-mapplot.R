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
    )
  )
}
mapplotServer <- function(id, leaflet_params, network) {
  shiny::moduleServer(id, function(input, output, session) {
    network_sf <- shiny::reactive({
      convert_sf(
        network(),
        leaflet_params$lat(),
        leaflet_params$lon()
        # leaflet_params$col()
      ) |>
        filter_sf(
          xmin = leaflet_params$BB()$west,
          xmax = leaflet_params$BB()$east,
          ymin = leaflet_params$BB()$south,
          ymax = leaflet_params$BB()$north
        )
    })
    output$plot <- shiny::renderPlot({
      if (leaflet_params$lat() != "none" & leaflet_params$lon() != "none") {
        plot_map(network_sf(), zoom = input$zoom)
      }
    })
  })
}
mapplotApp <- function(network_input) {
  meta <- igraph::vertex_attr_names(network_input)
  ui <- shiny::fluidPage(
    leafletInput("leaflet", meta),
    mapplotInput("map"),
    mapplotOutput("map"),
    leafletOutput("leaflet")
  )
  server <- function(input, output, session) {
    network <- shiny::reactive({
      network_input
    })
    mapplotServer("map", x, network)
    x <- leafletServer("leaflet", network)
  }
  shiny::shinyApp(ui, server)
}
# pacman::p_load(tidyverse)
# mapplotApp(example_network) |> print()

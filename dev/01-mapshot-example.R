library(leaflet)
m <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng = -118.243683, lat = 34.052235, popup = "Los Angeles")
m # display map
library(mapview)
library(webshot)
webshot::install_phantomjs()
# The file extension in the 'file' argument determines the output format
mapshot(m, file = "~/Downloads/my_leaflet_map.jpeg")

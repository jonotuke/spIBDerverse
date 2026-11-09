# app.R -- dev launcher for the spatial ERGM module (not part of the package)
library(shiny)
pkgload::load_all(".", quiet = TRUE)

spatialergmApp(example_network_5)

get_status <- function(msg) {
  if (msg == "All fine") {
    class <- "alert alert-success"
    type <- "Success: "
  } else {
    class <- "alert alert-danger"
    type <- "Warning: "
  }
  shiny::tags$div(
    class = class,
    shiny::tags$strong(type),
    shiny::tags$p(msg)
  )
}

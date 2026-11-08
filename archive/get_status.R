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

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  msg <- check_ibd_file("inst/extdata/ibd-no-iid1-iid2.tsv")
  msg2 <- check_ibd_file("inst/extdata/example-ibd-data.tsv")
  get_status(msg) |> print()
  get_status(msg2) |> print()
}

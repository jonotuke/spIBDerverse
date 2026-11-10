utils::globalVariables(
  c("pred", "type", "p.value")
)

# UI placeholders: the actual widgets are rendered server-side so they can
# appear/disappear depending on whether r$ergm() is NULL.
pairwiseInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::uiOutput(ns("pred_ui"))
}

pairwiseOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::uiOutput(ns("tab_ui"))
}

# r: list / reactiveValues containing `ergm`, a reactive returning an ergm
#    object or NULL (used as r$ergm()).
pairwiseServer <- function(id, r) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    ergm_model <- shiny::reactive(r$ergm())

    pred_choices <- shiny::reactive({
      model <- ergm_model()
      if (is.null(model)) {
        return(character(0))
      }
      get_ergm_preds_df(model) |>
        dplyr::filter(type == "categorical") |>
        dplyr::pull(pred) |>
        unique()
    })

    output$pred_ui <- shiny::renderUI({
      if (is.null(ergm_model())) {
        return(NULL)
      }
      choices <- pred_choices()
      # Keep the current selection if it still exists in the new model
      current <- shiny::isolate(input$pred)
      selected <- if (!is.null(current) && current %in% choices) {
        current
      } else {
        choices[1]
      }
      shiny::radioButtons(
        ns("pred"),
        "Choice pairwise variable",
        choices = choices,
        selected = selected
      )
    })

    output$tab_ui <- shiny::renderUI({
      if (is.null(ergm_model())) {
        return(NULL)
      }
      gt::gt_output(ns("tab"))
    })

    output$tab <- gt::render_gt({
      model <- ergm_model()
      shiny::req(model, input$pred)
      # Guard against a stale selection left over from a previous model
      shiny::req(input$pred %in% pred_choices())
      ergm_pairwise(
        ergm_model = model,
        term_string = input$pred
      ) |>
        gt::gt() |>
        gt::fmt_scientific(p.value) |>
        gt::tab_style_body(
          columns = p.value,
          style = gt::cell_fill(color = "lightblue"),
          fn = function(x) x <= 0.05
        )
    })
  })
}

# Demo app. The checkbox lets you toggle between a model and NULL to check
# that the radio buttons and table hide/show correctly.
pairwiseApp <- function(ergm_model) {
  ui <- shiny::fluidPage(
    shiny::checkboxInput("use_model", "Model available", value = TRUE),
    pairwiseInput("pairwise"),
    pairwiseOutput("pairwise")
  )
  server <- function(input, output, session) {
    r <- shiny::reactiveValues(
      ergm = shiny::reactive(if (isTRUE(input$use_model)) ergm_model else NULL)
    )
    pairwiseServer("pairwise", r)
  }
  shiny::shinyApp(ui, server)
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets, ergm, network)
  g <- convert_to_network(example_network)
  m <- ergm::ergm(
    g ~ edges +
      nodematch("genetic_sex", diff = TRUE) +
      nodemix("site") +
      nodecov("lat")
  ) |>
    suppressMessages()
  pairwiseApp(m) |> print()
}

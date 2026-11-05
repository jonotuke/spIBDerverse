keep_selected <- function(current, choices) {
  if (isTRUE(current %in% choices)) current else unname(choices[1])
}

label_choices <- function(x) {
  lookup <- internal_df()
  labels <- lookup$full_name[match(x, lookup$name)]
  labels <- ifelse(is.na(labels), x, labels)
  existing <- names(x)
  if (!is.null(existing)) {
    keep <- !is.na(existing) & nzchar(existing)
    labels[keep] <- existing[keep]
  }
  stats::setNames(x, labels)
}

network_ui_server <- function(input, session, r, choices = NULL) {
  palettes <- get_palettes()

  attr_type <- function(var) {
    net <- r$full_network()
    if (is.null(net) || is.null(var) || var == "none") {
      return(NA_character_)
    }
    x <- igraph::vertex_attr(net, var)
    if (is.numeric(x)) "continuous" else "discrete"
  }

  pal_choices <- function(type) {
    if (is.na(type)) {
      return("default")
    }
    c(
      "default",
      palettes |>
        dplyr::filter(type == !!type) |>
        dplyr::pull(name) |>
        sort()
    )
  }

  link_palette <- function(var_id, pal_id) {
    type <- shiny::reactive(attr_type(input[[var_id]]))

    shiny::observeEvent(type(), {
      pal <- pal_choices(type())
      shiny::updateSelectInput(
        session,
        pal_id,
        choices = pal,
        selected = keep_selected(input[[pal_id]], pal)
      )
    })

    type
  }

  # Attribute choices for a new network
  shiny::observeEvent(list(r$full_network(), input$internals), {
    net <- r$full_network()
    shiny::req(net)
    all_vars <- c(
      "none",
      get_node_attributes(net, inc_internals = input$internals)
    )
    num_vars <- c(
      "none",
      get_node_attributes(net, "num", inc_internals = input$internals)
    )
    cat_vars <- c(
      "none",
      get_node_attributes(net, "cat", inc_internals = input$internals)
    )

    new_choices <- list(
      fill = all_vars,
      outline_col = all_vars,
      label = all_vars,
      label_filter = all_vars,
      lat = all_vars,
      lon = all_vars,
      shape = cat_vars,
      size = num_vars,
      alpha = num_vars,
      edge = c("none", igraph::edge_attr_names(net))
    )
    if (is.function(choices)) {
      new_choices <- utils::modifyList(new_choices, choices(net))
    }

    new_choices <- lapply(new_choices, pretty_choices)

    for (nm in names(new_choices)) {
      shiny::updateSelectInput(
        session,
        nm,
        choices = new_choices[[nm]],
        selected = keep_selected(input[[nm]], new_choices[[nm]])
      )
    }
  })

  invisible(list(
    fill_type = link_palette("fill", "fill_pal"),
    col_type = link_palette("outline_col", "col_pal")
  ))
}

network_plot_args <- function(input) {
  list(
    lat = input$lat,
    long = input$lon,
    connected = input$connected,
    edge = input$edge,
    edge_legend = input$edge_legend,
    edge_trans = input$edge_trans,
    label = input$label,
    label_inc = input$label_inc,
    label_exc = input$label_exc,
    label_col = input$label_col,
    fill = input$fill,
    shape = input$shape,
    size = input$size,
    node_size = input$node_size,
    fill_pal = input$fill_pal,
    outline_col = input$outline_col,
    col_pal = input$col_pal,
    outline_width = input$outline_width,
    alpha = input$alpha
  )
}

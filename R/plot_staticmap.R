#' plot static-map
#'
#' @param sf network sf pobject
#' @param key stadia API key
#' @param zoom stadia tile zoom
#' @param maptype stadia map tile
#' @param lat_range range of lat to zoom to
#' @param lon_range range of lon to zoom to
#' @param fill vertex attribute for node fill
#' @param shape vertex attribute for node shape
#' @param node_size node size
#' @param node_centrality vertext attribute for node alpha
#' @param connected choice for how to deal with isolated nodes with choices
#' Hide, Show, Grey out
#' @param edge edge attribute for line colour
#' @param edge_legend boolean to control edge legend
#' @param edge_trans transformation for edge mapping
#' @param label vertex attribute to use for labels
#' @param label_size label size
#' @param label_inc regular expression to include labels
#' @param label_exc regular expression to exclude labels
#' @param theme type of plot theme
#'
#' @return network plot
#' @export
#'
#' @examples
#' plot_network(example_network)
plot_staticmap <- function(
  sf,
  key = NULL,
  zoom = 5,
  maptype = "stamen_terrain",
  lon_range = NULL,
  lat_range = NULL,
  fill = "none",
  shape = "none",
  node_size = 4,
  node_centrality = "none",
  connected = "Show",
  edge = "none",
  edge_legend = TRUE,
  edge_trans = "identity",
  label = "",
  label_inc = "",
  label_exc = "",
  label_size = 3,
  theme = "minimal"
) {
  # SETUP ----
  ggplot2::update_geom_defaults(
    "point",
    list(shape = 21, fill = "white")
  )
  # KEY ----
  if (is.null(key)) {
    message(
      "You need a stadia map key to use this
      See https://stadiamaps.com"
    )
    return(NULL)
  }
  ggmap::register_stadiamaps(
    key = key
  )
  # FILTER
  if (!is.null(lat_range) & !is.null(lon_range)) {
    sf <- sf |>
      filter_sf(
        xmin = lon_range[1],
        xmax = lon_range[2],
        ymin = lat_range[1],
        ymax = lat_range[2]
      )
  }
  # BOUNDING BOX ----
  nodes_sf <- sf$nodes_sf
  if (is.null(lat_range) | is.null(lon_range)) {
    BB <- sf::st_bbox(nodes_sf)
    names(BB) <- c("left", "bottom", "right", "top")
  } else {
    BB <- c(
      left = lon_range[1],
      bottom = lat_range[1],
      right = lon_range[2],
      top = lat_range[2]
    )
  }

  # TILES ----
  tile <- ggmap::get_stadiamap(
    BB,
    zoom = zoom,
    maptype = maptype
  )
  p <- ggmap::ggmap(tile)
  p
  # NODE ALPHA ----
  nodes_sf$alpha <- 1
  if (connected == "Hide") {
    nodes_sf <- nodes_sf |>
      dplyr::filter(degree >= 1)
  } else if (connected == "Grey out") {
    nodes_sf <- nodes_sf |>
      dplyr::mutate(
        alpha = ifelse(degree >= 1, 1, 0.1)
      )
  }
  if (node_centrality != "none") {
    nodes_sf <- nodes_sf |>
      dplyr::mutate(
        alpha = transform_alpha(
          .data[[node_centrality]],
          a = 0.1
        )
      )
  }
  # EDGES ----
  edges_sf <- sf$edges_sf
  if (edge %in% c("", "none")) {
    p <- p +
      ggplot2::geom_sf(
        data = edges_sf,
        inherit.aes = FALSE
      )
  } else {
    if (is.character(edges_sf[[edge]])) {
      p <- p +
        ggplot2::geom_sf(
          ggplot2::aes(
            linetype = .data[[edge]]
          ),
          show.legend = edge_legend,
          data = edges_sf,
          inherit.aes = FALSE
        )
    } else {
      p <- p +
        ggplot2::geom_sf(
          ggplot2::aes(
            colour = .data[[edge]],
            linewidth = .data[[edge]]
          ),
          show.legend = edge_legend,
          data = edges_sf,
          inherit.aes = FALSE,
        ) +
        ggplot2::scale_linewidth_continuous(
          range = c(0.5, 2),
          transform = edge_trans
        ) +
        ggplot2::scale_color_gradient2(
          low = "grey90",
          mid = "grey50",
          high = "black"
        ) +
        ggplot2::guides(colour = "none")
    }
  }
  # LABELS ----
  nodes_sf$label <- NA
  if (!label %in% c("", "none")) {
    label_sym <- get_sym(label)
    nodes_sf <- nodes_sf |>
      dplyr::mutate(label = {{ label_sym }})
    if (label_inc != "") {
      label_inc <- convert_pipe(label_inc)
      nodes_sf <- nodes_sf |>
        dplyr::mutate(
          label = dplyr::case_when(
            stringr::str_detect(label, label_inc) ~ name,
            TRUE ~ NA
          )
        )
    }
    if (label_exc != "") {
      label_exc <- convert_pipe(label_exc)
      nodes_sf <- nodes_sf |>
        dplyr::mutate(
          label = dplyr::case_when(
            stringr::str_detect(label, label_exc) ~ NA,
            TRUE ~ label
          )
        )
    }
  }
  if (fill %in% c("", "none")) {
    nodes_sf$label_colour <- "black"
  } else {
    nodes_sf$label_colour <- get_text_font(
      nodes_sf[[fill]],
      type = "text"
    )
  }
  # NODES ----
  fill_sym <- get_sym(fill)
  shape_sym <- get_sym(shape)
  p <- p +
    ggplot2::geom_sf(
      ggplot2::aes(
        shape = {{ shape_sym }}
      ),
      fill = "white",
      size = node_size,
      data = nodes_sf,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_sf(
      ggplot2::aes(
        fill = {{ fill_sym }},
        shape = {{ shape_sym }},
        alpha = alpha
      ),
      size = node_size,
      data = nodes_sf,
      inherit.aes = FALSE
    ) +
    ggplot2::scale_alpha_identity() +
    ggplot2::scale_shape_manual(
      values = rep(21:25, 1e4)
    )
  if (methods::is(nodes_sf[[fill]], "character")) {
    p <- p + harrypotter::scale_fill_hp_d("Ravenclaw")
  } else {
    p <- p + harrypotter::scale_fill_hp("Ravenclaw")
  }
  # LABELS ----
  p <- p + ggnewscale::new_scale_colour()
  p <- p +
    ggplot2::geom_sf_text(
      ggplot2::aes(
        label = label,
        colour = label_colour
      ),
      size = label_size,
      show.legend = FALSE,
      data = nodes_sf,
      inherit.aes = FALSE
    ) +
    ggplot2::scale_colour_identity()
  # EXTRAS ----
  p <- p + ggplot2::labs(x = "Longitude", y = "Latitude")
  p <- p +
    ggplot2::scale_x_continuous(labels = identity)
  p <- p +
    ggplot2::scale_y_continuous(labels = identity)
  p <- p + ggplot2::coord_sf(expand = c(0, 0))
  selected_theme <- dplyr::case_when(
    theme == "black white" ~ list(ggplot2::theme_bw()),
    theme == "void" ~ list(ggplot2::theme_void()),
    TRUE ~ list(ggplot2::theme_minimal())
  )[[1]]
  p <- p + selected_theme
  p <- p +
    ggplot2::guides(
      colour = "none",
      alpha = "none",
      fill = ggplot2::guide_legend(
        override.aes = list(linetype = NA)
      ),
      shape = ggplot2::guide_legend(
        override.aes = list(linetype = NA)
      )
    )
  p
}
# jono_key <- "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
# plot_staticmap(
#   example_sf,
#   key = jono_key,
#   zoom = 11,
#   fill = "site",
#   node_centrality = "degree",
#   edge = "edge_type",
#   edge_trans = "log10",
#   label = "site",
#   lat_range = c(-34.95, -34.6),
#   lon_range = c(138.5, 138.7)
# ) |>
#   print()

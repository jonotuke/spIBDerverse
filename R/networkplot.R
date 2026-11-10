#' add layout
#'
#' @param g igraph network
#' @param name name of layout
#'
#' @returns coords based on igraph layout
#'
#' @export
#' @examples
#' add_layout(example_network)
add_layout <- function(g, name = "nicely") {
  if (name == "circle") {
    igraph::layout_in_circle(g)
  } else if (name == "sphere") {
    igraph::layout_on_sphere(g)
  } else if (name == "dh") {
    igraph::layout_with_dh(g)
  } else if (name == "fr") {
    igraph::layout_with_fr(g)
  } else if (name == "kk") {
    igraph::layout_with_kk(g)
  } else if (name == "mds") {
    igraph::layout_with_mds(g)
  } else {
    igraph::layout_nicely(g)
  }
}
#' List available palettes
#'
#' Finds every `scale_fill_*()` function exported by the installed version of
#' ggsci, so the list stays current when ggsci is updated. Also includes
#' `"default"`, which gives ggplot2's own default scale and works for both
#' discrete and continuous data.
#'
#' @returns a data frame with the palette name (the value to pass as `pal`),
#'   whether it is discrete, continuous or both
get_palettes <- function() {
  pals <- getNamespaceExports("ggsci")
  pals <- tibble::tibble(name = pals)
  pals <- pals |>
    dplyr::filter(
      stringr::str_detect(
        name,
        "^scale_fill"
      )
    )
  pals <- pals |>
    dplyr::mutate(
      name = stringr::str_remove_all(name, "scale_fill_"),
    ) |>
    dplyr::distinct(name)
  pals <- pals |>
    dplyr::mutate(
      type = ifelse(
        name %in% c("gsea", "material", "bs5", "tw3"),
        "continuous",
        "discrete"
      )
    )
  pals <- dplyr::bind_rows(
    tibble::tibble(name = "default", type = "both"),
    pals
  )
  pals
}

#' Build a palette scale by name
#'
#' Internal helper that looks up `scale_<aesthetic>_<pal>()` in ggsci and
#' calls it, so any palette in your installed version of ggsci can be used.
#' Use `pal = "default"` to get ggplot2's default discrete or continuous
#' scale instead.
#'
#' @param aesthetic "fill" or "colour"/"color"
#' @param pal ggsci palette name, e.g. "npg", "lancet", "gsea", or "default"
#'   for the ggplot2 default
#' @param type "discrete" or "continuous". For ggsci palettes this is used for
#'   validation only; for `pal = "default"` it picks which ggplot2 scale to use.
#' @param ... passed on to the scale (e.g. `palette = "category20"`,
#'   `alpha = 0.8`, `reverse = TRUE` for ggsci; any ggplot2 scale argument
#'   such as `name` or `limits` for the default)
#'
#' @returns a ggplot2 scale
pal_scale <- function(aesthetic, pal, type = "discrete", ...) {
  type <- match.arg(type, c("discrete", "continuous"))

  if (pal == "default") {
    fn_name <- paste0("scale_", aesthetic, "_", type)
    if (!exists(fn_name, envir = asNamespace("ggplot2"), inherits = FALSE)) {
      stop(
        stringr::str_glue("{fn_name} is not in ggplot2; check `aesthetic`")
      )
    }
    return(getExportedValue("ggplot2", fn_name)(...))
  }

  pals <- get_palettes()
  pal_type <- pals |>
    dplyr::filter(name == pal) |>
    dplyr::pull(type)
  if (length(pal_type) == 0) {
    stop(
      stringr::str_glue("{pal} is not in ggsci package")
    )
  }
  if (pal_type != type) {
    stop(
      "Wrong palette type"
    )
  }

  fn_name <- paste0("scale_", aesthetic, "_", pal)
  if (!exists(fn_name, envir = asNamespace("ggsci"), inherits = FALSE)) {
    stop(
      "That palette is not in ggsci"
    )
  }
  getExportedValue("ggsci", fn_name)(...)
}
#' converts NA to unknown
#'
#' @param g igraph object
#' @param name node attribute to convert
#'
#' @returns updated igraph object
#'
#' @export
#' @examples
#' convert_na_unknown(example_network_3, "site")
convert_na_unknown <- function(g, name) {
  names <- get_node_attributes(g)
  if (!name %in% names) {
    stop(
      stringr::str_glue("{name} is not a node attribute")
    )
  }
  x <- igraph::vertex_attr(g, name)
  if (!is.numeric(x)) {
    x[is.na(x)] <- "Unknown"
    g <- igraph::set_vertex_attr(g, name, value = x)
  }
  g
}
#' converts all NAs in node attributes
#'
#' @param g igraph object
#'
#' @returns igraph object with all NAs converted
#'
#' @export
#' @examples
#' convert_nas_unknown(example_network_3)
convert_nas_unknown <- function(g) {
  names <- get_node_attributes(g)
  for (i in names) {
    g <- convert_na_unknown(g, i)
  }
  g
}

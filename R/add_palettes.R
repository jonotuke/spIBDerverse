#' List ggsci palettes
#'
#' Finds every `scale_fill_*()` function exported by the installed version of
#' ggsci, so the list stays current when ggsci is updated.
#'
#' @returns a data frame with the palette name (the value to pass as `pal`),
#'   whether it is discrete or continuous
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
  pals
}

#' Build a ggsci scale by name
#'
#' Internal helper that looks up `scale_<aesthetic>_<pal>()` in ggsci and
#' calls it, so any palette in your installed version of ggsci can be used.
#'
#' @param aesthetic "fill" or "color"
#' @param pal ggsci palette name, e.g. "npg", "lancet", "gsea"
#' @param type "discrete" or "continuous" (used for validation only)
#' @param ... passed on to the ggsci scale (e.g. `palette = "category20"`,
#'   `alpha = 0.8`, `reverse = TRUE`)
#'
#' @returns a ggplot2 scale
pal_scale <- function(aesthetic, pal, type = "discrete", ...) {
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


if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets, ggsci)
  get_palettes() |> print()
  p <- mpg |>
    ggplot(aes(displ, cty, colour = drv)) +
    geom_point(size = 4) +
    pal_scale(aesthetic = "colour", "lancet", type = "discrete")
  p |> print()

  p2 <- mpg |>
    ggplot(aes(displ, cty, colour = hwy)) +
    geom_point(size = 4) +
    pal_scale(
      aesthetic = "colour",
      "material",
      type = "continuous",
      palette = "cyan"
    )
  p2 |> print()
}

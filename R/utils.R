abbreviate_one <- function(x) {
  x |>
    stringr::str_remove_all("\\(.*\\)") |>
    stringr::str_split(" |-") |>
    purrr::pluck(1) |>
    stringr::str_sub(1, 1) |>
    stringr::str_c(collapse = "")
}
#' abbreviate labels
#'
#' @description
#' Takes first letter of each word, where a word is separated by space on hyphen
#' Also removes brackets first
#'
#' @param x vector of labels
#'
#' @returns vector of abbreviations
#'
#' @export
#' @examples
#' abbreviate_terms(c("Jono Tuke", "Adam Ben Rohrlach", "Adelaide-University"))
abbreviate_terms <- function(x) {
  x |> purrr::map_chr(abbreviate_one)
}
#' add stars to p-values
#'
#' @param pv p-values
#'
#' @returns stars
#'
#' @export
#' @examples
#' add_stars(0.05)
add_stars <- function(pv) {
  stars <- dplyr::case_when(
    dplyr::between(pv, 0, 0.001) ~ "***",
    dplyr::between(pv, 0.001, 0.01) ~ "**",
    dplyr::between(pv, 0.01, 0.05) ~ "*",
    dplyr::between(pv, 0.05, 0.1) ~ ".",
    dplyr::between(pv, 0.1, 1) ~ ""
  )
  stars
}
#' checks that vector of names are node attributes in a given
#' network
#'
#' @param g igraph object
#' @param preds vector of node attributes
#'
#' @returns error or NULL
#'
#' @export
#' @examples
#' check_node_attributes(example_network, c("lat", "site"))
check_node_attributes <- function(g, preds) {
  checkmate::assert_character(preds)
  missing <- setdiff(
    preds,
    igraph::vertex_attr_names(g)
  )
  if (length(missing) > 0) {
    rlang::abort(
      stringr::str_glue(
        "The following are not in the node attributes:{missing}"
      )
    )
  }
}
#' helper function to pass stop messages into shiny
#'
#' @param expr expression to run
#'
#' @returns shiny validate message
validate_try <- function(expr) {
  tryCatch(
    expr,
    error = function(e) shiny::validate(conditionMessage(e))
  )
}
if (sys.nframe() == 5) {
  validate_try(sqrt(-1)) |> print()
  sqrt(-1)
}
#' Transform vector to (a,b)
#'
#' @param x vector to transform
#' @param a lower bound of transform
#' @param b upper bound of transform
#'
#' @returns transformed vector
#'
#' @export
#' @examples
#' transform_alpha(runif(100))
transform_alpha <- function(x, a = 0, b = 1) {
  if (min(x, na.rm = TRUE) == max(x, na.rm = TRUE)) {
    stop("min is equal to max")
  }
  stopifnot(a < b)
  slope <- (b - a) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
  intercept <- a - slope * min(x, na.rm = TRUE)
  y <- intercept + slope * x
  y[is.na(y)] <- a
  y
}
#' convert pipe
#'
#' @param x string for inclusion exclusion
#'
#' @returns commas are replaced by pipe
#'
#' @export
#' @examples
#' convert_pipe("bob, harry")
convert_pipe <- function(x) {
  x |> stringr::str_replace_all(",", "|") |> stringr::str_remove_all(" ")
}
#' internal df
#'
#' A tibble of network internals
#'
#' @returns tibble
internal_df <- function() {
  tibble::tribble(
    ~name                  , ~full_name                    , ~type        ,
    ".degree"              , "Degree"                      , "centrality" ,
    ".closeness"           , "Closeness"                   , "centrality" ,
    ".betweenness"         , "Betweenness"                 , "centrality" ,
    ".eigencentrality"     , "Eigen-centrality"            , "centrality" ,
    ".louvain"             , "Louvain"                     , "clustering" ,
    ".louvain_weighted"    , "Weighted Louvain"            , "clustering" ,
    ".eigen"               , "Leading eigenvalue"          , "clustering" ,
    ".eigen_weighted"      , "Weighted leading eigenvalue" , "clustering" ,
    ".label_prop"          , "Label propagation"           , "clustering" ,
    ".label_prop_weighted" , "Weighted label propagation"  , "clustering"
  )
}
pretty_var_name <- function(x) {
  lookup_map <- stats::setNames(
    internal_df()$full_name,
    internal_df()$name
  )
  x <- ifelse(
    x %in% names(lookup_map),
    lookup_map[x],
    x
  )
  x
}
pretty_choices <- function(x) {
  lookup <- internal_df()
  labels <- pretty_var_name(x)
  stats::setNames(x, labels)
}
pretty_col <- function(df) {
  lookup <- stats::setNames(
    internal_df()$name,
    internal_df()$full_name
  )
  df <- df |>
    dplyr::rename(dplyr::any_of(lookup))
  df
}
hover_tooltip <- function(trigger, ...) {
  bslib::tooltip(trigger, ..., options = list(trigger = "hover"))
}
utils::globalVariables(
  c("pixel")
)
#' Plots a default image
#'
#' @returns an ASCII image
#'
#' @export
plot_default_image <- function() {
  spIBDerverse::default_image |>
    ggplot2::ggplot(
      ggplot2::aes(col, row, label = pixel)
    ) +
    ggplot2::geom_text() +
    ggplot2::scale_y_reverse() +
    ggplot2::theme_void() +
    ggplot2::coord_equal(ratio = 2)
}
#' get_connected_graph
#'
#' @param g igraph object
#'
#' @return igraph object
#' @export
#'
#' @examples
#' g <- igraph::sample_gnp(10, 0.5)
#' get_connected_graph(g)
get_connected_graph <- function(g) {
  components <- igraph::components(g, mode = "weak")
  connected_cluster_id <- which(components$csize > 1)
  node_id <- igraph::V(g)[components$membership %in% connected_cluster_id]
  igraph::induced_subgraph(g, node_id)
}
#' Get text font
#'
#' @description
#' Used to get contrasting text to a fill.
#'
#' @param x numeric vector to convert to colour
#' @param type whether to return the colour, or black / white for text
#'
#'
#' @returns vector of colours
#'
#' @export
#' @examples
#' get_text_font(1:10)
#' get_text_font(1:10, "text")
get_text_font <- function(x, type = "fill") {
  fill <- colourvalues::colour_values(x)
  fill_hcl <- farver::decode_colour(fill, "rgb", "hcl")
  text <- ifelse(fill_hcl[, "l"] > 50, "black", "white")
  if (type == "fill") {
    return(fill)
  } else {
    text
  }
}

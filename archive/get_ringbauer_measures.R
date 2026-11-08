utils::globalVariables(
  c(
    "name",
    "from",
    "to",
    "grp",
    "grp_from",
    "grp_to",
    "grp1",
    "grp2",
    "n",
    "n1",
    "n2",
    "n_edges",
    "n_possible_edges",
    "pv",
    "lwr",
    "upr",
    "prop_test"
  )
)
#' Get ringbauer measures
#'
#' Takes a network and a categorical node variable and calculates the intra-
#' and inter-level edge density for every pair of levels. Each density is
#' compared with the overall network density using a one-sample proportion
#' test, with FDR-adjusted p-values. The 95% confidence interval for each
#' density (from the same `prop.test()` call) is returned as `lwr` and `upr`.
#'
#' Nodes with a missing value of `grp` are dropped, along with their edges.
#' The network is treated as undirected.
#'
#' @param g igraph object with a `name` vertex attribute
#' @param grp a name of a categorical node variable
#'
#' @return tibble with one row per ordered pair of levels (`grp1`, `grp2`)
#'   and columns `n_edges`, `n1`, `n2`, `n_possible_edges`, `density`,
#'   `label`, `overall_density`, `lwr`, `upr`, `pv` and `adj_pv`
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site")
get_ringbauer_measures <- function(g, grp) {
  stopifnot(igraph::is_igraph(g), is.character(grp), length(grp) == 1)
  if (!"name" %in% igraph::vertex_attr_names(g)) {
    stop("`g` must have a `name` vertex attribute.", call. = FALSE)
  }
  if (!grp %in% igraph::vertex_attr_names(g)) {
    stop("`", grp, "` is not a vertex attribute of `g`.", call. = FALSE)
  }

  node_df <- igraph::as_data_frame(g, "vertices") |>
    tibble::as_tibble() |>
    dplyr::select(name, grp = dplyr::all_of(grp)) |>
    dplyr::filter(!is.na(grp))
  grps <- unique(node_df$grp)

  grp_sizes <- node_df |>
    dplyr::count(grp) |>
    dplyr::mutate(n = as.double(n))

  # Group membership of both ends of each edge (edges touching dropped
  # nodes fall out of the inner joins)
  edge_df <- igraph::as_data_frame(g, "edges") |>
    tibble::as_tibble() |>
    dplyr::select(from, to) |>
    dplyr::inner_join(
      dplyr::rename(node_df, grp_from = grp),
      by = c(from = "name")
    ) |>
    dplyr::inner_join(
      dplyr::rename(node_df, grp_to = grp),
      by = c(to = "name")
    )

  # Count each between-group edge in both orientations so that the
  # (A, B) and (B, A) rows both get the full count; within-group edges
  # are counted once
  edge_tally <- dplyr::bind_rows(
    dplyr::select(edge_df, grp1 = grp_from, grp2 = grp_to),
    edge_df |>
      dplyr::filter(grp_from != grp_to) |>
      dplyr::select(grp1 = grp_to, grp2 = grp_from)
  ) |>
    dplyr::count(grp1, grp2, name = "n_edges") |>
    dplyr::mutate(n_edges = as.double(n_edges))

  p <- igraph::edge_density(g)

  tidyr::expand_grid(grp1 = grps, grp2 = grps) |>
    dplyr::left_join(edge_tally, by = c("grp1", "grp2")) |>
    dplyr::left_join(
      dplyr::rename(grp_sizes, grp1 = grp, n1 = n),
      by = "grp1"
    ) |>
    dplyr::left_join(
      dplyr::rename(grp_sizes, grp2 = grp, n2 = n),
      by = "grp2"
    ) |>
    dplyr::mutate(
      n_edges = dplyr::coalesce(n_edges, 0),
      n_possible_edges = dplyr::if_else(
        grp1 == grp2,
        n1 * (n1 - 1) / 2,
        n1 * n2
      ),
      density = n_edges / n_possible_edges,
      label = stringr::str_glue("{n_edges}/{n_possible_edges}"),
      overall_density = p,
      prop_test = purrr::map2(
        n_edges,
        n_possible_edges,
        \(x, n) {
          tryCatch(
            {
              res <- stats::prop.test(x = x, n = n, p = p)
              tibble::tibble(
                lwr = res$conf.int[[1]],
                upr = res$conf.int[[2]],
                pv = res$p.value
              )
            },
            error = \(e) {
              tibble::tibble(lwr = NA_real_, upr = NA_real_, pv = NA_real_)
            }
          )
        }
      )
    ) |>
    tidyr::unnest(prop_test) |>
    dplyr::mutate(adj_pv = stats::p.adjust(pv, method = "fdr")) |>
    dplyr::relocate(n_edges, .after = grp2)
}
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets, ergm)
  get_ringbauer_measures(example_network, "site") |>
    print(n = Inf)
}

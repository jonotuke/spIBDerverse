utils::globalVariables(
  c("from", "to", "n_edges", "n_possible_edges")
)
#' Get ringbauer measures
#'
#' This takes a network and a categorical node variable and calculate the intra- and
#' inter- level density.
#'
#' @param g igraph object
#' @param grp a name of a categorical node variable
#'
#' @return tibble with density measures
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site")
get_ringbauer_measures <- function(g, grp) {
  node_df <- igraph::as_data_frame(g, "vertices") |>
    tibble::as_tibble() |>
    dplyr::select(name, grp = dplyr::all_of(grp))
  node_df <- node_df |> dplyr::filter(!is.na(grp))
  grps <- unique(node_df$grp)
  edge_df <- igraph::as_data_frame(g) |>
    dplyr::as_tibble() |>
    dplyr::select(from, to) |>
    dplyr::left_join(node_df, by = c(from = "name")) |>
    dplyr::left_join(node_df, by = c(to = "name")) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::starts_with("grp"),
        \(x) factor(x, levels = unique(node_df$grp))
      )
    )
  edge_count <-
    tidyr::expand_grid(grp1 = grps, grp2 = grps) |>
    dplyr::mutate(n_edges = 0, n1 = 0, n2 = 0, n_possible_edges = 0)
  for (i in 1:nrow(edge_count)) {
    grp1 <- edge_count$grp1[i]
    grp2 <- edge_count$grp2[i]
    if (grp1 == grp2) {
      n <- sum(node_df$grp == grp1)
      edge_count$n1[i] <- n
      edge_count$n2[i] <- n
      edge_count$n_possible_edges[i] <- n * (n - 1) / 2
      edge_count$n_edges[i] <- sum(
        edge_df$grp.x == grp1 & edge_df$grp.y == grp2
      )
    } else {
      n1 <- sum(node_df$grp == grp1)
      edge_count$n1[i] <- n1
      n2 <- sum(node_df$grp == grp2)
      edge_count$n2[i] <- n2
      edge_count$n_possible_edges[i] <- n1 * n2
      edge_count$n_edges[i] <- sum(
        (edge_df$grp.x == grp1 &
          edge_df$grp.y == grp2) |
          (edge_df$grp.x == grp2 & edge_df$grp.y == grp1)
      )
    }
  }
  edge_count <- edge_count |>
    dplyr::mutate(
      density = n_edges / n_possible_edges,
      label = stringr::str_glue("{n_edges}/{n_possible_edges}")
    )
  p <- igraph::edge_density(g)
  edge_count$pv <- 1
  for (i in 1:nrow(edge_count)) {
    edge_count$pv[i] <-
      tryCatch(
        stats::prop.test(
          x = edge_count$n_edges[i],
          n = edge_count$n_possible_edges[i],
          p = p
        )$p.value,
        error = function(e) {
          return(NA)
        }
      )
  }
  edge_count <- edge_count |>
    dplyr::mutate(
      adj_pv = stats::p.adjust(pv, method = "fdr")
    )

  edge_count
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# get_ringbauer_measures(example_network, "site") |>
#   print(n = Inf)

# Tests for get_ringbauer_measures()
#
# Small networks give low expected counts, so prop.test() warns that the
# chi-squared approximation may be incorrect. Those warnings are expected
# and are suppressed throughout.

# Helpers ---------------------------------------------------------------------

run_rm <- function(...) suppressWarnings(get_ringbauer_measures(...))

ref_prop_test <- function(x, n, p) suppressWarnings(stats::prop.test(x, n, p))

get_row <- function(res, a, b) res[res$grp1 == a & res$grp2 == b, ]

# Toy network with known answers:
#   group A = a, b, c   group B = d, e
#   edges: a-b, a-c (A-A), d-e (B-B), a-d, b-e (A-B)
#   A-A: 2 of 3 possible   B-B: 1 of 1   A-B: 2 of 6
#   overall density: 5 of 10 = 0.5
make_toy <- function(extra_nodes = NULL, extra_edges = NULL) {
  nodes <- data.frame(
    name = c("a", "b", "c", "d", "e"),
    site = c("A", "A", "A", "B", "B")
  )
  edges <- data.frame(
    from = c("a", "a", "d", "a", "b"),
    to = c("b", "c", "e", "d", "e")
  )
  igraph::graph_from_data_frame(
    rbind(edges, extra_edges),
    directed = FALSE,
    vertices = rbind(nodes, extra_nodes)
  )
}

# Input validation ------------------------------------------------------------

test_that("non-igraph input is rejected", {
  expect_error(get_ringbauer_measures(data.frame(x = 1), "site"))
})

test_that("grp must be a single character string", {
  g <- make_toy()
  expect_error(get_ringbauer_measures(g, 1))
  expect_error(get_ringbauer_measures(g, c("site", "name")))
})

test_that("a graph without a name attribute is rejected", {
  g <- igraph::make_ring(4)
  g <- igraph::set_vertex_attr(g, "site", value = c("A", "A", "B", "B"))
  expect_error(get_ringbauer_measures(g, "site"), "name")
})

test_that("an unknown grouping attribute is rejected", {
  expect_error(
    get_ringbauer_measures(make_toy(), "not_there"),
    "not a vertex attribute"
  )
})

# Output structure ------------------------------------------------------------

test_that("output is a tibble with the documented columns in order", {
  res <- run_rm(make_toy(), "site")
  expect_s3_class(res, "tbl_df")
  expect_named(
    res,
    c(
      "grp1",
      "grp2",
      "n_edges",
      "n1",
      "n2",
      "n_possible_edges",
      "density",
      "label",
      "overall_density",
      "lwr",
      "upr",
      "pv",
      "adj_pv"
    )
  )
})

test_that("there is one row per ordered pair of levels", {
  res <- run_rm(make_toy(), "site")
  expect_equal(nrow(res), 4)
  expect_setequal(paste(res$grp1, res$grp2), c("A A", "A B", "B A", "B B"))
})

# Counts and densities --------------------------------------------------------

test_that("edge counts, group sizes and possible edges are correct", {
  res <- run_rm(make_toy(), "site")

  aa <- get_row(res, "A", "A")
  expect_equal(aa$n_edges, 2)
  expect_equal(aa$n1, 3)
  expect_equal(aa$n2, 3)
  expect_equal(aa$n_possible_edges, 3)

  bb <- get_row(res, "B", "B")
  expect_equal(bb$n_edges, 1)
  expect_equal(bb$n_possible_edges, 1)

  ab <- get_row(res, "A", "B")
  expect_equal(ab$n_edges, 2)
  expect_equal(ab$n_possible_edges, 6)
})

test_that("between-group rows are symmetric", {
  res <- run_rm(make_toy(), "site")
  ab <- get_row(res, "A", "B")
  ba <- get_row(res, "B", "A")
  cols <- c("n_edges", "n_possible_edges", "density", "lwr", "upr", "pv")
  expect_equal(as.list(ab[cols]), as.list(ba[cols]))
})

test_that("density and label are consistent with the counts", {
  res <- run_rm(make_toy(), "site")
  expect_equal(res$density, res$n_edges / res$n_possible_edges)
  expect_equal(
    as.character(res$label),
    paste0(res$n_edges, "/", res$n_possible_edges)
  )
  expect_equal(get_row(res, "A", "A")$density, 2 / 3)
})

test_that("overall density matches igraph::edge_density()", {
  g <- make_toy()
  res <- run_rm(g, "site")
  expect_equal(unique(res$overall_density), igraph::edge_density(g))
  expect_equal(unique(res$overall_density), 0.5)
})

# Proportion test and confidence interval -------------------------------------

test_that("pv, lwr and upr match a direct call to prop.test()", {
  res <- run_rm(make_toy(), "site")
  for (i in seq_len(nrow(res))) {
    ref <- ref_prop_test(res$n_edges[i], res$n_possible_edges[i], p = 0.5)
    expect_equal(res$pv[i], ref$p.value)
    expect_equal(res$lwr[i], ref$conf.int[[1]])
    expect_equal(res$upr[i], ref$conf.int[[2]])
  }
})

test_that("confidence intervals are valid and contain the density", {
  res <- run_rm(make_toy(), "site")
  expect_true(all(res$lwr >= 0 & res$upr <= 1))
  expect_true(all(res$lwr <= res$density & res$density <= res$upr))
})

test_that("adj_pv is the FDR adjustment of pv", {
  res <- run_rm(make_toy(), "site")
  expect_equal(res$adj_pv, stats::p.adjust(res$pv, method = "fdr"))
})

# Edge cases ------------------------------------------------------------------

test_that("a singleton group gives NA test results for its own pair", {
  g <- make_toy(extra_nodes = data.frame(name = "f", site = "C"))
  res <- run_rm(g, "site")

  cc <- get_row(res, "C", "C")
  expect_equal(cc$n_possible_edges, 0)
  expect_true(is.na(cc$pv))
  expect_true(is.na(cc$lwr))
  expect_true(is.na(cc$upr))
  expect_true(is.na(cc$adj_pv))

  # Other rows are still tested, and NA p-values don't break the adjustment
  expect_false(is.na(get_row(res, "A", "C")$pv))
  expect_equal(res$adj_pv, stats::p.adjust(res$pv, method = "fdr"))
})

test_that("nodes with a missing group are dropped along with their edges", {
  base <- run_rm(make_toy(), "site")
  g <- make_toy(
    extra_nodes = data.frame(name = "z", site = NA),
    extra_edges = data.frame(from = c("z", "z"), to = c("a", "d"))
  )
  res <- run_rm(g, "site")

  expect_setequal(unique(res$grp1), c("A", "B"))
  # Counts and the CI (which doesn't depend on the null value) are unchanged
  cols <- c(
    "grp1",
    "grp2",
    "n_edges",
    "n1",
    "n2",
    "n_possible_edges",
    "density",
    "lwr",
    "upr"
  )
  expect_equal(res[cols], base[cols])
})

test_that("a numeric grouping attribute works", {
  g <- make_toy()
  igraph::V(g)$num_site <- ifelse(igraph::V(g)$site == "A", 1, 2)
  res <- run_rm(g, "num_site")
  expect_equal(nrow(res), 4)
  expect_equal(get_row(res, 1, 1)$n_edges, 2)
})

# Tests for load_ibd_network() and read_delimited_file()
#
# Place in tests/testthat/. Tests run inside the package namespace, so the
# internal helpers (read_delimited_file, %spib%, add_centrality_measures) are
# visible. add_centrality_measures() is mocked as the identity in most tests so
# that load_ibd_network() is tested in isolation.

# Helpers -----------------------------------------------------------------

# Write a data frame to a temporary file that is deleted when `env` exits.
write_temp <- function(df, ext = ".tsv", env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ext, .local_envir = env)
  if (grepl("csv", ext)) {
    readr::write_csv(df, path)
  } else {
    readr::write_tsv(df, path)
  }
  path
}

# A small, fully valid IBD table. Pairs are chosen so that each one tests a
# different filter with the default cutoffs ibd_co = c(0, 2, 1, 0) and
# frac_co = 0.7.
make_ibd <- function() {
  tibble::tibble(
    iid1 = c("A", "A", "B", "C", "D"),
    iid2 = c("B", "C", "C", "D", "E"),
    n_ibd_8 = c(5, 5, 5, 5, 5),
    n_ibd_12 = c(3, 1, 2, 4, 4), # A-C fails n_ibd_12 >= 2
    n_ibd_16 = c(2, 2, 1, 0, 3), # C-D fails n_ibd_16 >= 1
    n_ibd_20 = c(1, 1, 0, 0, 1),
    sum_ibd_8 = c(10.5, 20, 30.25, 40, 50)
  )
}

# Metadata: E has low frac_gp, so D-E fails the frac_co filter. C sits exactly
# on the default frac_co of 0.7. F has no edges.
make_meta <- function() {
  tibble::tibble(
    iid = c("A", "B", "C", "D", "E", "F"),
    frac_gp = c(0.9, 0.8, 0.7, 0.95, 0.5, 0.99),
    pop = c("p1", "p1", "p2", "p2", "p3", "p3")
  )
}

# Run load_ibd_network() on in-memory data frames.
run_load <- function(
  ibd = make_ibd(),
  meta = make_meta(),
  ...,
  ibd_ext = ".tsv",
  meta_ext = ".tsv"
) {
  ibd_file <- write_temp(ibd, ibd_ext)
  meta_file <- write_temp(meta, meta_ext)
  load_ibd_network(ibd_file, meta_file, ...)
}

edge_pairs <- function(g) {
  el <- igraph::as_edgelist(g)
  sort(apply(el, 1, function(x) paste(sort(x), collapse = "-")))
}

identity_centrality <- function(env = parent.frame()) {
  local_mocked_bindings(add_centrality_measures = function(g) g, .env = env)
}

# read_delimited_file() ---------------------------------------------------

test_that("read_delimited_file reads csv files", {
  df <- data.frame(a = 1:3, b = c("x", "y", "z"))
  path <- write_temp(df, ".csv")
  out <- read_delimited_file(path)
  expect_s3_class(out, "tbl_df")
  expect_equal(as.data.frame(out), df, ignore_attr = TRUE)
})

test_that("read_delimited_file reads tsv, tab and txt files as tab-separated", {
  df <- data.frame(a = 1:2, b = c("x,1", "y,2")) # commas inside values
  for (ext in c(".tsv", ".tab", ".txt")) {
    path <- write_temp(df, ext)
    out <- read_delimited_file(path)
    expect_equal(colnames(out), c("a", "b"), info = ext)
    expect_equal(out$b, c("x,1", "y,2"), info = ext)
  }
})

test_that("read_delimited_file ignores compression suffixes", {
  df <- data.frame(a = 1:3, b = c("x", "y", "z"))
  csv_gz <- withr::local_tempfile(fileext = ".csv.gz")
  readr::write_csv(df, csv_gz)
  tsv_gz <- withr::local_tempfile(fileext = ".tsv.gz")
  readr::write_tsv(df, tsv_gz)

  expect_equal(colnames(read_delimited_file(csv_gz)), c("a", "b"))
  expect_equal(colnames(read_delimited_file(tsv_gz)), c("a", "b"))
  expect_equal(nrow(read_delimited_file(csv_gz)), 3)
})

test_that("read_delimited_file treats extensions case-insensitively", {
  df <- data.frame(a = 1:2, b = 3:4)
  path <- withr::local_tempfile(fileext = ".CSV")
  readr::write_csv(df, path)
  expect_equal(colnames(read_delimited_file(path)), c("a", "b"))
})

test_that("read_delimited_file guesses the delimiter for unknown extensions", {
  df <- data.frame(a = 1:2, b = 3:4)
  comma <- withr::local_tempfile(fileext = ".dat")
  readr::write_csv(df, comma)
  tab <- withr::local_tempfile(fileext = ".dat")
  readr::write_tsv(df, tab)

  expect_equal(colnames(read_delimited_file(comma)), c("a", "b"))
  expect_equal(colnames(read_delimited_file(tab)), c("a", "b"))
})

test_that("read_delimited_file errors on a missing file", {
  path <- file.path(tempdir(), "definitely-not-here.csv")
  expect_error(read_delimited_file(path))
})

# load_ibd_network(): argument validation ---------------------------------

test_that("ibd_co must be a numeric vector of length 4", {
  expect_message(
    out <- load_ibd_network("x.tsv", "y.tsv", ibd_co = c(1, 2, 3)),
    "ibd_co must be a numeric vector of length 4"
  )
  expect_null(out)

  expect_message(
    out <- load_ibd_network("x.tsv", "y.tsv", ibd_co = c("0", "2", "1", "0")),
    "ibd_co must be a numeric vector of length 4"
  )
  expect_null(out)

  expect_message(
    out <- load_ibd_network("x.tsv", "y.tsv", ibd_co = numeric(0)),
    "length 4"
  )
  expect_null(out)
})

# load_ibd_network(): reading inputs --------------------------------------

test_that("an unreadable IBD file returns NULL with a message", {
  missing <- file.path(tempdir(), "no-such-ibd.tsv")
  meta_file <- write_temp(make_meta())
  expect_message(
    out <- load_ibd_network(missing, meta_file),
    "Cannot read in .*no-such-ibd.tsv"
  )
  expect_null(out)
})

test_that("an unreadable metadata file returns NULL with a message", {
  ibd_file <- write_temp(make_ibd())
  missing <- file.path(tempdir(), "no-such-meta.tsv")
  expect_message(
    out <- load_ibd_network(ibd_file, missing),
    "Cannot read in .*no-such-meta.tsv"
  )
  expect_null(out)
})

test_that("missing required IBD columns are reported and return NULL", {
  ibd <- make_ibd() |> dplyr::select(-n_ibd_16, -sum_ibd_8)
  expect_message(
    out <- run_load(ibd = ibd),
    "missing these columns: n_ibd_16, sum_ibd_8"
  )
  expect_null(out)
})

test_that("IBD column names are cleaned with janitor::clean_names", {
  identity_centrality()
  ibd <- make_ibd()
  colnames(ibd) <- c(
    "IID1",
    "IID2",
    "N_IBD_8",
    "N_IBD_12",
    "N_IBD_16",
    "N_IBD_20",
    "Sum IBD 8"
  )
  g <- run_load(ibd = ibd)
  expect_s3_class(g, "igraph")
  expect_equal(edge_pairs(g), c("A-B", "B-C"))
})

test_that("CSV inputs work as well as TSV inputs", {
  identity_centrality()
  g_tsv <- run_load()
  g_csv <- run_load(ibd_ext = ".csv", meta_ext = ".csv")
  expect_equal(edge_pairs(g_csv), edge_pairs(g_tsv))
})

# load_ibd_network(): metadata handling -----------------------------------

test_that("first metadata column is used as iid when iid is absent", {
  identity_centrality()
  meta <- make_meta() |> dplyr::rename(sample_id = iid)
  expect_message(
    g <- run_load(meta = meta),
    "The column iid is not in the META file"
  )
  expect_s3_class(g, "igraph")
  expect_setequal(igraph::V(g)$name, make_meta()$iid)
})

test_that("iid is moved to the first column of the metadata", {
  identity_centrality()
  meta <- make_meta() |> dplyr::relocate(iid, .after = pop)
  g <- run_load(meta = meta)
  expect_s3_class(g, "igraph")
  expect_setequal(igraph::V(g)$name, make_meta()$iid)
  expect_equal(
    igraph::V(g)$pop[match(c("A", "E"), igraph::V(g)$name)],
    c("p1", "p3")
  )
})

test_that("missing frac_gp in metadata returns NULL when IBD lacks it too", {
  meta <- make_meta() |> dplyr::select(-frac_gp)
  expect_message(
    out <- run_load(meta = meta),
    "does not have a column called frac_gp"
  )
  expect_null(out)
})

test_that("frac_gp1/frac_gp2 in the IBD file are used directly", {
  identity_centrality()
  ibd <- make_ibd() |>
    dplyr::mutate(frac_gp1 = 0.9, frac_gp2 = c(0.9, 0.9, 0.9, 0.9, 0.9))
  meta <- make_meta() |> dplyr::select(-frac_gp) # not needed now
  g <- run_load(ibd = ibd, meta = meta)
  expect_s3_class(g, "igraph")
  # D-E now passes frac_co because the IBD file's values take precedence
  expect_equal(edge_pairs(g), c("A-B", "B-C", "D-E"))
})

test_that("a lone frac_gp1 column is replaced by metadata values", {
  identity_centrality()
  ibd <- make_ibd() |> dplyr::mutate(frac_gp1 = 0) # would fail everything
  g <- run_load(ibd = ibd)
  expect_s3_class(g, "igraph")
  expect_equal(edge_pairs(g), c("A-B", "B-C"))
})

# load_ibd_network(): edge selection --------------------------------------

test_that("default cutoffs keep only pairs passing every filter", {
  identity_centrality()
  g <- run_load()
  # A-C fails n_ibd_12 >= 2; C-D fails n_ibd_16 >= 1; D-E fails frac_gp
  # (E = 0.5). B-C sits exactly on the n_ibd_12, n_ibd_16 and frac_gp cutoffs.
  expect_equal(edge_pairs(g), c("A-B", "B-C"))
})

test_that("frac_co is inclusive and applied to both nodes", {
  identity_centrality()
  # C has frac_gp exactly 0.7, so B-C is kept at frac_co = 0.7 ...
  g <- run_load(frac_co = 0.7)
  expect_true("B-C" %in% edge_pairs(g))
  # ... and dropped once the cutoff is raised above it.
  g <- run_load(frac_co = 0.71)
  expect_false("B-C" %in% edge_pairs(g))
  # Lowering the cutoff below E's 0.5 lets D-E through.
  g <- run_load(frac_co = 0.5)
  expect_true("D-E" %in% edge_pairs(g))
})

test_that("each ibd_co element filters its own column, inclusively", {
  identity_centrality()
  base <- tibble::tibble(
    iid1 = "A",
    iid2 = "B",
    n_ibd_8 = 2,
    n_ibd_12 = 2,
    n_ibd_16 = 2,
    n_ibd_20 = 2,
    sum_ibd_8 = 1
  )
  # Exactly at the cutoff: kept
  g <- run_load(ibd = base, ibd_co = c(2, 2, 2, 2))
  expect_equal(igraph::ecount(g), 1)
  # One above the value in each position in turn: dropped
  for (i in 1:4) {
    co <- c(2, 2, 2, 2)
    co[i] <- 3
    g <- run_load(ibd = base, ibd_co = co)
    expect_equal(igraph::ecount(g), 0, info = paste("ibd_co position", i))
  }
})

test_that("permissive cutoffs keep every pair with good frac_gp", {
  identity_centrality()
  g <- run_load(ibd_co = c(0, 0, 0, 0), frac_co = 0)
  expect_equal(igraph::ecount(g), nrow(make_ibd()))
})

test_that("pairs with a node missing from metadata are dropped by frac_gp", {
  identity_centrality()
  ibd <- dplyr::bind_rows(
    make_ibd(),
    tibble::tibble(
      iid1 = "A",
      iid2 = "Z",
      n_ibd_8 = 9,
      n_ibd_12 = 9,
      n_ibd_16 = 9,
      n_ibd_20 = 9,
      sum_ibd_8 = 99
    )
  )
  # Z has no frac_gp (NA after the join), so the pair never reaches igraph
  g <- run_load(ibd = ibd)
  expect_s3_class(g, "igraph")
  expect_false("Z" %in% igraph::V(g)$name)
})

test_that("no passing pairs yields a graph with all nodes and no edges", {
  identity_centrality()
  g <- run_load(ibd_co = c(100, 100, 100, 100))
  expect_s3_class(g, "igraph")
  expect_equal(igraph::ecount(g), 0)
  expect_equal(igraph::vcount(g), nrow(make_meta()))
})

# load_ibd_network(): filter_on_meta --------------------------------------

test_that("nodes absent from metadata cause a graph error unless filtered", {
  identity_centrality()
  ibd <- make_ibd() |> dplyr::mutate(frac_gp1 = 0.9, frac_gp2 = 0.9)
  ibd$iid2[1] <- "Z" # A-Z passes all cutoffs but Z is not in the metadata

  expect_message(
    expect_message(
      out <- run_load(ibd = ibd, filter_on_meta = FALSE),
      "Cannot create igraph object"
    ),
    "Message is: .*vertex"
  )
  expect_null(out)

  g <- run_load(ibd = ibd, filter_on_meta = TRUE)
  expect_s3_class(g, "igraph")
  expect_false("Z" %in% igraph::V(g)$name)
  expect_false(any(grepl("Z", edge_pairs(g))))
})

# load_ibd_network(): graph structure -------------------------------------

test_that("the graph is undirected with metadata nodes and attributes", {
  identity_centrality()
  g <- run_load()
  expect_false(igraph::is_directed(g))
  expect_setequal(igraph::V(g)$name, make_meta()$iid)
  # Isolated metadata nodes are retained
  expect_equal(unname(igraph::degree(g)["F"]), 0)
  # Metadata columns become vertex attributes
  expect_true(all(c("frac_gp", "pop") %in% igraph::vertex_attr_names(g)))
  a <- which(igraph::V(g)$name == "A")
  expect_equal(igraph::V(g)$frac_gp[a], 0.9)
})

test_that("edge weight wij equals sum_ibd_8 and edge data is carried over", {
  identity_centrality()
  g <- run_load()
  expect_true(all(
    c("wij", "sum_ibd_8", "frac_gp1", "frac_gp2", "n_ibd_8") %in%
      igraph::edge_attr_names(g)
  ))
  expect_equal(igraph::E(g)$wij, igraph::E(g)$sum_ibd_8)
  el <- igraph::as_edgelist(g)
  ab <- which(el[, 1] == "A" & el[, 2] == "B" | el[, 1] == "B" & el[, 2] == "A")
  expect_equal(igraph::E(g)$wij[ab], 10.5)
  # frac_gp values are joined from metadata for the right node
  expect_equal(igraph::E(g)$frac_gp1[ab], 0.9)
  expect_equal(igraph::E(g)$frac_gp2[ab], 0.8)
})

test_that("add_centrality_measures is applied to the graph and returned", {
  calls <- 0
  local_mocked_bindings(add_centrality_measures = function(g) {
    calls <<- calls + 1
    expect_s3_class(g, "igraph")
    igraph::set_graph_attr(g, "centrality_added", TRUE)
  })
  g <- run_load()
  expect_equal(calls, 1)
  expect_true(igraph::graph_attr(g, "centrality_added"))
})

test_that("add_centrality_measures is not called when loading fails", {
  calls <- 0
  local_mocked_bindings(add_centrality_measures = function(g) {
    calls <<- calls + 1
    g
  })
  suppressMessages(run_load(meta = make_meta() |> dplyr::select(-frac_gp)))
  expect_equal(calls, 0)
})

test_that("the real pipeline (no mocks) returns an igraph object", {
  g <- run_load()
  expect_s3_class(g, "igraph")
  expect_equal(igraph::vcount(g), nrow(make_meta()))
})
